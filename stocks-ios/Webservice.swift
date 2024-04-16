//
//  Webservice.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/6/24.
//

import Foundation
import UIKit
import Kingfisher
import Foundation
import WebKit


struct companyDescData: Identifiable, Decodable {
    let id: UUID = UUID()
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let name: String
    let ticker: String
    let weburl: String
    
    enum CodingKeys: String, CodingKey {
        case finnhubIndustry, ipo, logo, name, ticker, weburl
    }
    
}

struct StockPrice: Decodable {
    let currentPrice: Double
    let Change: Double
    let PercentChange: Double
    let high: Double
    let low: Double
    let open: Double
    let previousClose: Double
    let timestamp: Int

    enum CodingKeys: String, CodingKey {
        case currentPrice = "c"
        case Change = "d"
        case PercentChange = "dp"
        case high = "h"
        case low = "l"
        case open = "o"
        case previousClose = "pc"
        case timestamp = "t"
    }
}

struct NewsItem: Decodable, Identifiable {
    let id: Int
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}

class WebService: ObservableObject {
    
    static let service = WebService()
    private let baseUrl = URL(string: "http://localhost:8080/")!
    @Published var autocompleteSuggestions: [FilteredAutoResult] = []
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.5
    @Published var descData: companyDescData?
    @Published var stockData: StockPrice?
    @Published var peers: [String] = []
    @Published var insiderSums = InsiderSums()
//    typealias Recommendations = [Recommendation]
//    @Published var recommendationData: Recommendations = []
    @Published var filteredNewsItems: [NewsItem] = []
    @Published var recommendationChartDataJson: String?
    @Published var EPSChartDataJson: String?
    @Published var HourlyChartDataJson: String?
    @Published var HistoricalChartDataJson: String?
    
    func fetchAPI() {
        getCompanyDesc { result in
            switch result {
            case .success(let companyDesc):
                    self.descData = companyDesc
                    // Handle successful retrieval of the company description
               // print("Company Description: \(self.descData)")
                
            case .failure(let error):
                // Handle error
                print("Error fetching company description: \(error)")
            }

            // Note: This is a simple example. In a real app, consider how you want to handle
            // the asynchronous nature of these calls, especially if you need both results
            // together for further processing.
        }

        getStockPrice { result in
            switch result {
            case .success(let stockPrice):
                self.stockData = stockPrice
                // Handle successful retrieval of the stock price
                //print("Stock Price: \(self.stockData)")
            case .failure(let error):
                // Handle error
                print("Error fetching stock price: \(error)")
            }
        }
        getCompanyPeers { result in
            switch result {
            case .success(let companyP):
               
                self.peers = companyP
//                print("Company Peers: \(self.peers)")
            case .failure(let error):
                // Handle error
                print("Error fetching peers: \(error)")
            }
        }
        getinsiderSent { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let insiderResponse):
                        let sums = insiderResponse.calculateSums()
                        self.insiderSums.positiveChangeSum = sums.positiveChange
                        self.insiderSums.negativeChangeSum = sums.negativeChange
                        self.insiderSums.positiveMsprSum = sums.positiveMspr
                        self.insiderSums.negativeMsprSum = sums.negativeMspr
//                        print("Insider Data Success: \(sums)")
                    case .failure(let error):
                        print("Error fetching insider sentiment data: \(error)")
                    }
                }
            }
        
//        getrecomChartData { result in
//                    DispatchQueue.main.async {
//                        switch result {
//                        case .success(let recommendations):
//                            self.recommendationData = recommendations
//                        case .failure(let error):
//                            print("Error fetching recommendation data: \(error)")
//                        }
//                    }
//                }
        
        getNewsData { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newsItems):
                        // Filter news items to include only those with a non-empty image link
                        // and then take only the first 10 items
                        let filteredWithImages = newsItems.filter { !$0.image.isEmpty }
                        self?.filteredNewsItems = Array(filteredWithImages.prefix(10))
//                        print("Filtered News Items: \(self?.filteredNewsItems.count ?? 0)")
                    case .failure(let error):
                        // Handle error
                        print("Error fetching news data: \(error)")
                        self?.filteredNewsItems = []
                    }
                }
            }
            
        
        fetchRecommendationChartData()
        fetchEPSChartData()
//        fetchHourlyChartData()
//        fetchHistoricalChartData()
        
    }
        
    

    // Generic method to fetch data from the server
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
    
    func getCompanyDesc(completion: @escaping (Result<companyDescData, Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("companyDesc/\(SharedData.shared.ticker)")
        fetchData(url: url, completion: completion)
    }
    
    func getStockPrice(completion: @escaping (Result<StockPrice, Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("stockPrice/\(SharedData.shared.ticker)")
        fetchData(url: url, completion: completion)
    }
    
    func getCompanyPeers(completion: @escaping (Result<[String], Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("companyPeers/\(SharedData.shared.ticker)")
        fetchData(url: url, completion: completion)
    }
    
    func getinsiderSent(completion: @escaping (Result<insiderResponse, Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("insiderSentiment/\(SharedData.shared.ticker)")
        fetchData(url: url, completion: completion)
    }
    

    
    func getNewsData(completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("companyNews/\(SharedData.shared.ticker)")
        fetchData(url: url, completion: completion)
    }
    
    
    func fetchRecommendationChartData() {
        let urlString = "http://localhost:8080/recommendation/\(SharedData.shared.ticker)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching recommendation data: \(error)")
                    self?.recommendationChartDataJson = nil // Clear any existing data if error occurs
                    return
                }

                guard let data = data else {
                    print("No data received")
                    self?.recommendationChartDataJson = nil // Clear any existing data if no data received
                    return
                }

                // Convert to a non-optional JSON object to remove "Optional" wrapper
                if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    self?.recommendationChartDataJson = jsonString
//                    print("Recommendation Chart JSON: \(jsonString)")
                } else {
                    print("Data could not be converted to JSON string")
                    self?.recommendationChartDataJson = nil // Clear any existing data if conversion fails
                }
            }
        }

        task.resume()
    }
    
    func fetchEPSChartData() {
        let urlString = "http://localhost:8080/companyEarnings/\(SharedData.shared.ticker)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching recommendation data: \(error)")
                    self?.EPSChartDataJson = nil // Clear any existing data if error occurs
                    return
                }

                guard let data = data else {
                    print("No data received")
                    self?.EPSChartDataJson = nil // Clear any existing data if no data received
                    return
                }

                // Convert to a non-optional JSON object to remove "Optional" wrapper
                if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    self?.EPSChartDataJson = jsonString
//                    print("Recommendation Chart JSON: \(jsonString)")
                } else {
                    print("Data could not be converted to JSON string")
                    self?.EPSChartDataJson = nil // Clear any existing data if conversion fails
                }
            }
        }

        task.resume()
    }
    
    func fetchHourlyChartData() {
        let urlString = "http://localhost:8080/companyHourly/\(SharedData.shared.ticker)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching recommendation data: \(error)")
                    self?.HourlyChartDataJson = nil // Clear any existing data if error occurs
                    return
                }

                guard let data = data else {
                    print("No data received")
                    self?.HourlyChartDataJson = nil // Clear any existing data if no data received
                    return
                }

                // Convert to a non-optional JSON object to remove "Optional" wrapper
                if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    self?.HourlyChartDataJson = jsonString
//                    print("Recommendation Chart JSON: \(jsonString)")
                } else {
                    print("Data could not be converted to JSON string")
                    self?.HourlyChartDataJson = nil // Clear any existing data if conversion fails
                }
            }
        }

        task.resume()
    }
    
    func fetchHistoricalChartData() {
        let urlString = "http://localhost:8080/historicalChart/\(SharedData.shared.ticker)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching recommendation data: \(error)")
                    self?.HistoricalChartDataJson = nil // Clear any existing data if error occurs
                    return
                }

                guard let data = data else {
                    print("No data received")
                    self?.HistoricalChartDataJson = nil // Clear any existing data if no data received
                    return
                }

                // Convert to a non-optional JSON object to remove "Optional" wrapper
                if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    self?.HistoricalChartDataJson = jsonString
//                    print("Historical Chart JSON: \(jsonString)")
                } else {
                    print("Data could not be converted to JSON string")
                    self?.HistoricalChartDataJson = nil // Clear any existing data if conversion fails
                }
            }
        }

        task.resume()
    }
    

        

//    func fetchAutocompleteResults(query: String) {
//        let url = baseUrl.appendingPathComponent("autocomplete/\(query)")
//        fetchData(url: url) { [weak self] (result: Result<AutocompleteResponse, Error>) in
//            DispatchQueue.main.async {
//                print(result)
//                switch result {
//                case .success(let response):
//                    let filteredResults = response.result.filter { result in
//                        return result.type == "Common Stock" && !result.symbol.contains(".")
//                    }
//                    let simplifiedResults = filteredResults.map {
//                        FilteredAutoResult(description: $0.description, displaySymbol: $0.displaySymbol)
//                    }
//                    self?.autocompleteSuggestions = simplifiedResults
//                case .failure(let error):
//                    print("Error occurred: \(error.localizedDescription)")
//                    self?.autocompleteSuggestions = []
//                }
//            }
//        }
//    }
//
    
    
    
    func fetchAutocompleteResults(query: String) {
            print(query)
            debounceWorkItem?.cancel()

            let requestWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }

                let urlString = "autocomplete/\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let url = self.baseUrl.appendingPathComponent(urlString)

                self.fetchData(url: url) { (result: Result<AutocompleteResponse, Error>) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            let filteredResults = response.result.filter { result in
                                return result.type == "Common Stock" && !result.symbol.contains(".")
                            }
                            let simplifiedResults = filteredResults.map {
                                FilteredAutoResult(description: $0.description, displaySymbol: $0.displaySymbol)
                            }
                            self.autocompleteSuggestions = simplifiedResults
                        case .failure(let error):
                            print("Error occurred: \(error.localizedDescription)")
                            self.autocompleteSuggestions = []
                        }
                    }
                }
            }

            debounceWorkItem = requestWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: requestWorkItem)
        }
//    
//    func updateRecomChartData(webView: WKWebView, data: String) {
//        let script = "loadDataForRecomChart(\(data));"
//        webView.evaluateJavaScript(script) { (result, error) in
//            if let error = error {
//                print("Error injecting data into WebView:", error.localizedDescription)
//            }
//        }
//    }
    
    
    // Example structs for parsing JSON responses (you need to adjust these according to your actual JSON structure)
    
    struct AutocompleteResponse: Decodable {
        let count: Int
        let result: [AutocompleteResult]
    }
    
    struct AutocompleteResult: Decodable {
        let description: String
        let displaySymbol: String
        let symbol: String
        let type: String?
        let primary: [String]?
        
        enum CodingKeys: String, CodingKey {
            case description, displaySymbol, symbol, type, primary
        }
    }
    
    struct FilteredAutoResult:Identifiable,Hashable{
        let id: UUID = UUID()
        let description: String
        let displaySymbol: String
    }
    
    
    
    
    struct insiderResponse: Decodable {
        let data: [insiderData]
        let symbol: String
        
        // Function to calculate the sums
        func calculateSums() -> (positiveChange: Int, negativeChange: Int, positiveMspr: Double, negativeMspr: Double) {
            let positiveChange = data.filter { $0.change > 0 }.reduce(0) { $0 + $1.change }
            let negativeChange = data.filter { $0.change < 0 }.reduce(0) { $0 + $1.change }
            let positiveMspr = data.filter { $0.mspr > 0 }.reduce(0.0) { $0 + $1.mspr }
            let negativeMspr = data.filter { $0.mspr < 0 }.reduce(0.0) { $0 + $1.mspr }
            
            return (positiveChange, negativeChange, positiveMspr, negativeMspr)
        }
    }

    struct insiderData: Decodable {
        let symbol: String
        let year: Int
        let month: Int
        let change: Int
        let mspr: Double
    }
    
    struct InsiderSums {
        var positiveChangeSum: Int = 0
        var negativeChangeSum: Int = 0
        var positiveMsprSum: Double = 0.0
        var negativeMsprSum: Double = 0.0
    }
    
//    struct Recommendation: Codable {
//        let buy: Int
//        let hold: Int
//        let period: String
//        let sell: Int
//        let strongBuy: Int
//        let strongSell: Int
//        let symbol: String
//    }
//    
    

    
}
