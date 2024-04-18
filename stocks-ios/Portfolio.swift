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

    private let portfolioURL = URL(string: "http://localhost:3001/api/portfolio")!

    // Initialize ViewModel and fetch portfolio
//    init() {
//        fetchPortfolio()
//    }

    // Fetch portfolio from the backend API
    func fetchPortfolio() {
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
        let stockPriceURL = URL(string: "http://localhost:8080/stockPrice/\(symbol)")!
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
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Cash Balance")
                        .font(.title3)
                    Text(String(format: "$%.2f", portfolioViewModel.portfolioData?.balance ?? 0))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical)
        }
        // Now, instead of using a ForEach to create the list of stocks, the rows will be created in the parent List.
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
                    Text("\(stock.quantity) shares")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", stock.marketValue))
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: stock.changeInPrice > 0.01 ? "arrow.up.right" : stock.changeInPrice < 0.01 ? "arrow.down.right" : "minus")
                            .foregroundColor(stock.changeInPrice > 0.01 ? .green : stock.changeInPrice < 0.01 ? .red : .gray)
                        Text(String(format: "$%.2f (%.2f%%)", stock.changeInPrice, stock.changeInPricePercentage))
                            .foregroundColor(stock.changeInPrice > 0.01 ? .green : stock.changeInPrice < 0.01 ? .red : .gray)
                            .font(.subheadline)
                    }
                }
            }
        }
        // Here, we don't add padding or a background because the parent List will style the rows.
    }
}


