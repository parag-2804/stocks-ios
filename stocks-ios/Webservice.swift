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
    
    
    private let baseUrl = URL(string: "http://localhost:8080/")!
    @Published var autocompleteSuggestions: [FilteredAutoResult] = []
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.5
    
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
    
    func getCompanyDesc(ticker: String, completion: @escaping (Result<CompanyDesc, Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("companyDesc/\(ticker)")
        fetchData(url: url, completion: completion)
    }
    
    func getStockPrice(ticker: String, completion: @escaping (Result<StockPrice, Error>) -> Void) {
        let url = baseUrl.appendingPathComponent("stockPrice/\(ticker)")
        fetchData(url: url, completion: completion)
    }
    
    // Add similar methods for other endpoints...
    
    
    // Example method for autocomplete
    //    func getDataAutoComplete(queryVal: String, completion: @escaping (Result<[AutocompleteResult], Error>) -> Void) {
    //        let url = baseUrl.appendingPathComponent("autocomplete/\(queryVal)")
    //        fetchData(url: url, completion: completion)
    //    }
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
    
    
    
//    func fetchAutocompleteResults(query: String) {
//            // Cancel the current debounce work item if it exists
//            debounceWorkItem?.cancel()
//            
//            // Create a new work item to handle the API request
//            debounceWorkItem = DispatchWorkItem { [weak self] in
//                var urlComponents = URLComponents(url: self?.baseUrl.appendingPathComponent("autocomplete") ?? URL(fileURLWithPath: ""), resolvingAgainstBaseURL: true)
//                urlComponents?.queryItems = [URLQueryItem(name: "query", value: query)]
//                
//                guard let url = urlComponents?.url else { return }
//                
//                URLSession.shared.dataTask(with: url) { data, response, error in
//                    DispatchQueue.main.async {
//                        guard let data = data, error == nil else {
//                            print("Network error: \(error?.localizedDescription ?? "Unknown error")")
//                            self?.autocompleteSuggestions = []
//                            return
//                        }
//                        
//                        do {
//                            let results = try JSONDecoder().decode(AutocompleteResponse.self, from: data)
//                            print(results)
//                            let filteredResults = results.result.filter {
//                                ($0.type ?? "") == "Common Stock" && !($0.symbol).contains(".")
//                            }
//                            self?.autocompleteSuggestions = filteredResults.map {
//                                FilteredAutoResult(description: $0.description, displaySymbol: $0.displaySymbol)
//                            }
//                        } catch {
//                            print("Decoding error: \(error.localizedDescription)")
//                            self?.autocompleteSuggestions = []
//                        }
//                    }
//                }.resume()
//            }
//            
//            // Schedule the debounce work item to execute after a 0.5-second delay
//            if let debounceWorkItem = debounceWorkItem {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: debounceWorkItem)
//            }
//        }
    
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
    
    struct FilteredAutoResult:Identifiable{
        let id: UUID = UUID()
        let description: String
        let displaySymbol: String
    }
    struct CompanyDesc: Decodable {
        // Define properties based on your JSON structure
    }
    
    struct StockPrice: Decodable {
        // Define properties based on your JSON structure
    }
    
    //struct : Decodable {
    //
    //}
    
    
    // Define other structs as needed...
    
}
