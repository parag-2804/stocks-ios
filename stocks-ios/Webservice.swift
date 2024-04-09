//
//  Webservice.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/6/24.
//

import Foundation
import UIKit

import Foundation

class WebService: ObservableObject {
    
    static let service = WebService()
    private let baseUrl = URL(string: "http://localhost:8080/")!
    @Published var autocompleteSuggestions: [FilteredAutoResult] = []
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.5
    @Published var descData: companyDescData?
    @Published var peers: [String] = []
    
    func fetchAPI() {
        getCompanyDesc { result in
            switch result {
            case .success(let companyDesc):
                    self.descData = companyDesc
                    // Handle successful retrieval of the company description
                print("Company Description: \(self.descData)")
                
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
                // Handle successful retrieval of the stock price
                print("Stock Price: \(stockPrice)")
            case .failure(let error):
                // Handle error
                print("Error fetching stock price: \(error)")
            }
        }
        getCompanyPeers { result in
            switch result {
            case .success(let companyP):
                // Handle successful retrieval of the stock price
                self.peers = companyP
                print("Company Peers: \(self.peers)")
            case .failure(let error):
                // Handle error
                print("Error fetching peers: \(error)")
            }
        }
        
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
    
    
    // Add similar methods for other endpoints...
    
    
 
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
    
    struct companyDescData: Identifiable, Decodable {
        let id: UUID = UUID()
        let finnhubIndustry: String
        let ipo: String
        let name: String
        let ticker: String
        let weburl: String
        
        enum CodingKeys: String, CodingKey {
            case finnhubIndustry, ipo, name, ticker, weburl
        }
        
    }
    struct StockPrice: Decodable {
        // Define properties based on your JSON structure
    }
    
//    struct CompanyPeers: Decodable {
//        let peers: [String]
//        
//        // Custom initializer isn't necessary unless the JSON structure is more complex
//        // If the JSON is directly an array of strings, you can decode it as such.
//    }
//    
    
    
    //struct : Decodable {
    //
    //}
    
    
    // Define other structs as needed...
    
}
