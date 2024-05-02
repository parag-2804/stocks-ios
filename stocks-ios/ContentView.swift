////
////  ContentView.swift
////  stocks-ios
////
////  Created by Parag Jadhav on 4/3/24.
////
//
import SwiftUI
import UIKit



//
//class SharedData: ObservableObject {
//    static let shared = SharedData() // Shared instance
//    @Published var ticker: String = "AAPL"
//}




struct ContentView: View {
//    @State var isEditMode: EditMode = .inactive
    @State private var query: String = ""
//    @StateObject var webService = WebService()
    @EnvironmentObject var webService: WebService
    @EnvironmentObject var viewModel: Watchlist
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State var isWatchlistLoaded: Bool = false
    @State var isPortLoaded: Bool = false
    @State var ticker: String = ""
    @State private var isLoading: Bool = true
    // State to manage the selected suggestion
    @State private var isselected: Bool = false
    
    var body: some View {
        NavigationStack {
            
            if isLoading {
                ProgressView("Fetching Data...")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                        }
                    }
            } else {
                List {
                    if query.isEmpty {
                        
                        Section{
                            headerView()
                        }
                        
                        Section(header: Text("Portfolio")) {
                            PortfolioView()
                            
                            // Display the stock rows here so that they inherit the list's properties.
                            //                        if let stocks = portfolioViewModel.portfolioData?.stocklist, !stocks.isEmpty {
                            //                            ForEach(stocks) { stock in
                            //                                PortfolioRowView(stock: stock)
                            //                            }
                            //                            .onMove(perform: { (source: IndexSet, destination: Int) in
                            //                                portfolioViewModel.portfolioData?.stocklist.move(fromOffsets: source, toOffset: destination)
                            //                            })
                            //
                            //
                            //                        }
                            //                                     else {
                            //                                        Text("No stocks in portfolio.")
                            //                                    }
                            
                        }.onAppear {
                            portfolioViewModel.fetchPortfolio()
                        }
                        
                        
                        Section(header: Text("Favourites")){
                            favView()
                        } .onAppear {
                            viewModel.fetchWatchlist()
                        }
                        
                        Section{
                            footerView()
                        }
                        
                    } else {
                        // Search results
                        ForEach(webService.autocompleteSuggestions) { suggestion in
                            VStack(alignment: .leading) {
                                Text(suggestion.displaySymbol).fontWeight(.bold)
                                Text(suggestion.description).foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                
                                ticker = suggestion.displaySymbol
                                //                            webService.fetchAPI(ticker: ticker)
                                isselected = true
                            }
                        }
                    }
                }
                
                .navigationBarTitle("Stocks")
                .toolbar{
                    EditButton()
                    //                    .environment(\.editMode, $isEditMode)
                }
                //            .navigationBarItems(trailing: editButton)
                .searchable(text: $query, prompt: "Search")
                .onChange(of: query) { _ in
                    webService.fetchAutocompleteResults(query: query)
                }
                NavigationLink(destination: StockInfoView(ticker: ticker), isActive: $isselected) {
                    EmptyView()
                }
                .hidden()
                
            }
        }
                .onAppear {
                    viewModel.fetchWatchlist()
                    portfolioViewModel.fetchPortfolio()
                }
        
        
    }

}



    
    
    
    // View for the header with the date
    struct headerView:  View {
        let currentDate = Date()
        var body: some View{
            
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(8)
                Text(Utility.formatDate(currentDate))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)

                
            }
            .frame(height: 40)

        }
    }
    
    
    // View for the footer with the Finnhub.io link
    struct footerView: View {
        var body: some View{
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(8)
                
                
                Link("Powered by Finnhub.io", destination: URL(string: "https://www.finnhub.io")!)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
    
    // Preview
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            
            ContentView()
                .environmentObject(WebService.service)
                .environmentObject(Watchlist())
                .environmentObject(PortfolioViewModel())
            
        }
    }
    
