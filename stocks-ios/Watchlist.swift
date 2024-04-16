
import Foundation
import UIKit
import Kingfisher
import Foundation
import WebKit
import SwiftUI

struct MongoDBStockItem: Decodable {
    let symbol: String
    let company: String

    enum CodingKeys: String, CodingKey {
        case symbol = "Symbol"
        case company = "CompanyName"
    }
}

struct MongoDBResponse: Decodable {
    var _id: String
    var stock: [MongoDBStockItem]
}

struct StockItem: Identifiable, Codable {
    let id: UUID = UUID()
    var symbol: String
    var company: String
    var price: Double?
    var change: Double?
    var changePercentage: Double?
}



// ViewModel to handle fetching data and managing state
class Watchlist: ObservableObject {
    
    @Published var stocks: [StockItem] = []
    
    private let mongobaseUrl = URL(string: "http://localhost:3001/api/")!
    private let BaseUrl = URL(string: "http://localhost:8080/")!

    func fetchWatchlist() {
        let watchlistUrl = mongobaseUrl.appendingPathComponent("watchlist")

        URLSession.shared.dataTask(with: watchlistUrl) { [weak self] (data, response, error) in
            guard let self = self else { return }

            do {
                if let data = data {
                    let mongoDBResponses = try JSONDecoder().decode([MongoDBResponse].self, from: data)
                    var initialStockItems = mongoDBResponses.flatMap { $0.stock.map { StockItem(symbol: $0.symbol, company: $0.company) } }
                    
                    // Create a dispatch group to fetch additional details for each stock
                    let dispatchGroup = DispatchGroup()

                    for (index, stockItem) in initialStockItems.enumerated() {
                        dispatchGroup.enter() // Enter the dispatch group
                        self.getStockPrice(for: stockItem.symbol) { result in
                            switch result {
                            case .success(let stockPrice):
                                initialStockItems[index].price = stockPrice.currentPrice
                                initialStockItems[index].change = stockPrice.Change
                                initialStockItems[index].changePercentage = stockPrice.PercentChange
                            case .failure(let error):
                                print("Error fetching stock price for \(stockItem.symbol): \(error)")
                            }
                            dispatchGroup.leave() // Leave the dispatch group
                        }
                    }
                    
                    // After all the data has been fetched
                    dispatchGroup.notify(queue: .main) {
                        self.stocks = initialStockItems
                        print("Fetched stocks with additional details: \(self.stocks)")
                    }
                } else {
                    print("No data from watchlist")
                }
            } catch {
                print("Error decoding watchlist: \(error)")
            }
        }.resume()
    }

    func getStockPrice(for symbol: String, completion: @escaping (Result<StockPrice, Error>) -> Void) {
        let stockPriceUrl = BaseUrl.appendingPathComponent("stockPrice/\(symbol)")

        URLSession.shared.dataTask(with: stockPriceUrl) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            do {
                let stockPrice = try JSONDecoder().decode(StockPrice.self, from: data)
                completion(.success(stockPrice))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func addStockToWatchlist(symbol: String, companyName: String) {
        // Assuming you want to use the same base URL that is used for fetching the watchlist
        let url = mongobaseUrl.appendingPathComponent("watchlist")

        // Prepare the JSON payload
        let body: [String: Any] = ["Symbol": symbol, "CompanyName": companyName]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error: Cannot create JSON from stock data")
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: Network request failed: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            do {
                // Handle the response or parse JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response: \(json)")
                }
            } catch {
                print("Error: Failed to parse JSON response")
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
    
}
//
//struct favView: View {
//    @EnvironmentObject var viewModel: Watchlist
//    @EnvironmentObject var webService: WebService
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            ForEach(viewModel.stocks) { stock in
//                NavigationLink(destination: StockInfoView().onAppear {
//                    SharedData.shared.ticker = stock.symbol
//                    webService.fetchAPI()// Update the ticker when the view appears
//                }){
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(stock.symbol)
//                                .font(.headline)
//                            Text(stock.company)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        Spacer()
//                        
//                        VStack(alignment: .trailing) {
//                            Text(String(format: "$%.2f", stock.price ?? 0))
//                                .font(.headline)
//                            HStack(spacing: 4) {
//                                Image(systemName: (stock.change ?? 0) < 0 ? "arrow.down.right" : "arrow.up.right")
//                                    .foregroundColor((stock.change ?? 0) < 0 ? .red : .green)
//                                Text(String(format: "%.2f (%.2f%%)", stock.change ?? 0, stock.changePercentage ?? 0))
//                                    .foregroundColor((stock.change ?? 0) < 0 ? .red : .green)
//                            }
//                            .font(.subheadline)
//                        }
//                    }
//
//                }
//            }
//        }
//    }
//}
struct favView: View {
    @EnvironmentObject var viewModel: Watchlist
    @EnvironmentObject var webService: WebService
    @State private var isActive = false
    @State private var selectedStock: StockItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(viewModel.stocks) { stock in
                NavigationLink(destination: StockInfoView().onAppear {
                    self.setUpNavigation(for: stock)
                }, isActive: $isActive) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stock.symbol)
                                .font(.headline)
                            Text(stock.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(String(format: "$%.2f", stock.price ?? 0))
                                .font(.headline)
                            HStack(spacing: 4) {
                                Image(systemName: (stock.change ?? 0) < 0 ? "arrow.down.right" : "arrow.up.right")
                                    .foregroundColor((stock.change ?? 0) < 0 ? .red : .green)
                                Text(String(format: "%.2f (%.2f%%)", stock.change ?? 0, stock.changePercentage ?? 0))
                                    .foregroundColor((stock.change ?? 0) < 0 ? .red : .green)
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .simultaneousGesture(TapGesture().onEnded {
                    self.selectedStock = stock
                    self.isActive = true  // Set isActive to true to trigger navigation
                })
            }
        }
    }

    private func setUpNavigation(for stock: StockItem) {
        SharedData.shared.ticker = stock.symbol
        webService.fetchAPI()
    }
}




//
//struct favView: View {
//    @EnvironmentObject var viewModel: Watchlist
//
//    var body: some View {
//        ForEach(viewModel.stocks) { stock in
//            NavigationLink(destination: StockInfoView()) {
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(stock.symbol)
//                            .font(.headline)
//                        Text(stock.company)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                    Spacer()
//                    VStack(alignment: .trailing) {
//                        Text(String(format: "$%.2f", stock.price ?? 0))
//                            .font(.headline)
//                        HStack(spacing: 4) {
//                            Image(systemName: (stock.change ?? 0) < 0 ? "arrow.down.right" : "arrow.up.right")
//                                .foregroundColor((stock.change ?? 0) < 0 ? .red : .green)
//                            Text(String(format: "%.2f (%.2f%%)", stock.change ?? 0, stock.changePercentage ?? 0))
//                                .foregroundColor((stock.change ?? 0) < 0 ? .red : .green)
//                        }
//                        .font(.subheadline)
//                    }
//                }
//            }
//            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                Button(role: .destructive) {
//                    if let index = viewModel.stocks.firstIndex(where: { $0.id == stock.id }) {
//                        viewModel.stocks.remove(at: index)
//                    }
//                } label: {
//                    Label("Delete", systemImage: "trash")
//                }
//            }
//            .swipeActions(edge: .leading, allowsFullSwipe: true) {
//                Button {
//                    // Here you would normally handle some action.
//                    // For reordering, SwiftUI provides the Edit mode with onMove.
//                } label: {
//                    Label("Change", systemImage: "pencil")
//                }
//            }
//        }
//        
//        .onAppear {
//                    viewModel.fetchWatchlist()
//                }
//    }
//}





