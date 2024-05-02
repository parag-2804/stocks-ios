//
//  Portfolio.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/17/24.
//

import Foundation
import UIKit
import Kingfisher
import Foundation
import WebKit
import SwiftUI


struct Stock: Identifiable, Codable {
    var id: UUID = UUID()
    var symbol: String
    var name: String
    var quantity: Int
    var buyPrice: Double
    var latestQuote: Double?

    var marketValue: Double {
        guard let latestQuote = latestQuote else { return 0 }
        return Double(quantity) * latestQuote
    }

    var changeInPrice: Double {
        guard let latestQuote = latestQuote else { return 0 }
        return (latestQuote - buyPrice) * Double(quantity)
    }

    var changeInPricePercentage: Double {
        guard let latestQuote = latestQuote else { return 0 }
        return ((latestQuote - buyPrice) / buyPrice) * 100
    }
    
    var changeinPort: Double {
        return (marketValue - (buyPrice*Double(quantity)))
    }

    enum CodingKeys: String, CodingKey {
        case symbol = "Symbol"
        case name = "Name"
        case quantity = "Quantity"
        case buyPrice = "BuyPrice"
        
    }
}


// The PortfolioData structure is used to hold the entire portfolio which includes a balance and a list of stocks.
struct PortfolioData: Identifiable, Codable {
    let id: String
    var balance: Double
    var stocklist: [Stock]

    // Net worth is not part of the JSON and is a computed property.
    var netWorth: Double {
        return balance + stocklist.reduce(0) { $0 + $1.marketValue }
    }

    // Coding keys to match the JSON structure from the API
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case balance = "Balance"
        case stocklist = "Stocks"
    }
}

// This structure is used to decode the latest stock quote from the API.
struct LatestStockPrice: Codable {
    let latestQuote: Double
    enum CodingKeys: String, CodingKey {
        case latestQuote = "c"
    }
    
    
}




class PortfolioViewModel: ObservableObject {
    @Published var portfolioData: PortfolioData?
    
    private let portfolioURL = URL(string: "https://parag2804backend.wl.r.appspot.com/api/portfolio")!
    

    
    // Fetch portfolio from the backend API
    func fetchPortfolio(completion: @escaping () -> Void = {}) {
        URLSession.shared.dataTask(with: portfolioURL) { [weak self] data, response, error in
            if let data = data, error == nil {
                do {
                    let portfolios = try JSONDecoder().decode([PortfolioData].self, from: data)
                    DispatchQueue.main.async {
                        self?.portfolioData = portfolios.first
                        self?.fetchLatestStockQuotes()
                    }
                } catch {
                    print("Error decoding portfolio: \(error.localizedDescription)")
                }
            } else {
                print("Error fetching portfolio: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    // Fetch the latest stock quotes for each stock symbol
    func fetchLatestStockQuotes() {
        guard var stocks = portfolioData?.stocklist else { return }
        
        for i in stocks.indices {
            getStockPrice(for: stocks[i].symbol) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let stockPrice):
                        stocks[i].latestQuote = stockPrice.latestQuote
                        // Manually update the stock in portfolioData's stocklist.
                        self?.portfolioData?.stocklist[i] = stocks[i]
                        // Manually notify observers that the portfolioData has changed
                        self?.objectWillChange.send()
                    case .failure(let error):
                        print("Error getting stock price for symbol \(stocks[i].symbol): \(error)")
                    }
                }
            }
        }
    }
    
    
    // Function to fetch the latest stock price from your API
    func getStockPrice(for symbol: String, completion: @escaping (Result<LatestStockPrice, Error>) -> Void) {
        let stockPriceURL = URL(string: "https://parag2804backend.wl.r.appspot.com/stockPrice/\(symbol)")!
        // Replace with actual network call to your stock price API
        URLSession.shared.dataTask(with: stockPriceURL) { data, response, error in
            if let data = data, error == nil {
                do {
                    let stockPrice = try JSONDecoder().decode(LatestStockPrice.self, from: data)
                    completion(.success(stockPrice))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
            }
        }.resume()
    }
    
    
    
    func buyStock(symbol: String, name: String, quantity: Int, buyPrice: Double, stockPresent: Bool, balance: Double) {
        guard let url = URL(string: "https://parag2804backend.wl.r.appspot.com/api/portfolio/buyStock") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "symbol": symbol,
            "name": name,
            "quantity": quantity,
            "buyPrice": buyPrice,
            "stockPresent": stockPresent,
            "balance": balance
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response")
                return
            }
            
            guard httpResponse.statusCode == 200, let jsonData = data else {
                print("Error: Server returned status code \(httpResponse.statusCode)")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let message = json["message"] as? String {
                    print("Server Response: \(message)")
                } else {
                    print("Error: Unexpected server response format")
                }
            } catch {
                print("Error: Failed to parse JSON response")
            }
        }.resume()
    }




    func sellStock(symbol: String, quantity: Int, newPrice: Double, balance: Double) {
    guard let url = URL(string: "https://parag2804backend.wl.r.appspot.com/api/portfolio/updateStock") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "stockSymbol": symbol,
        
        "newQuantity": quantity,
        
        "newBuyPrice" : newPrice,
        
        "newBalance": balance
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error: Invalid response")
            return
        }
        
        guard httpResponse.statusCode == 200, let jsonData = data else {
            print("Error: Server returned status code \(httpResponse.statusCode)")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let message = json["message"] as? String {
                print("Server Response: \(message)")
            } else {
                print("Error: Unexpected server response format")
            }
        } catch {
            print("Error: Failed to parse JSON response")
        }
    }.resume()
}
}

struct PortfolioView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel

    var body: some View {
        // This VStack will contain only the header information.
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Net Worth")
                        .font(.title3)
                    Text(String(format: "$%.2f", portfolioViewModel.portfolioData?.netWorth ?? 0))
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Cash Balance")
                        .font(.title3)
                    Text(String(format: "$%.2f", portfolioViewModel.portfolioData?.balance ?? 0))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
        }
        
        if let stocks = portfolioViewModel.portfolioData?.stocklist, !stocks.isEmpty {
            ForEach(stocks) { stock in
                PortfolioRowView(stock: stock)
            }
            .onMove(perform: { (source: IndexSet, destination: Int) in
                portfolioViewModel.portfolioData?.stocklist.move(fromOffsets: source, toOffset: destination)
            })
            
            
        }
  
    }
}

struct PortfolioRowView: View {
    var stock: Stock
    
    var body: some View {
        NavigationLink(destination: StockInfoView(ticker: stock.symbol))
        {
            HStack {
                VStack(alignment: .leading) {
                    Text(stock.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("\(stock.quantity) shares")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", stock.marketValue))
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 25) {
                        Image(systemName: stock.changeInPrice > 0 ? "arrow.up.right" : stock.changeInPrice < 0 ? "arrow.down.right" : "minus")
                            .foregroundColor(stock.changeInPrice > 0 ? .green : stock.changeInPrice < 0 ? .red : .gray)
                        Text(String(format: "$%.2f (%.2f%%)", stock.changeInPrice, stock.changeInPricePercentage))
                            .foregroundColor(stock.changeInPrice > 0 ? .green : stock.changeInPrice < 0 ? .red : .gray)
                            .font(.subheadline)
                    }
                }
            }
        }

    }
}


