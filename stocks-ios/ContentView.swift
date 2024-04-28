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
    @State var isEditMode: EditMode = .inactive
    @State private var query: String = ""
//    @StateObject var webService = WebService()
    @EnvironmentObject var webService: WebService
    @EnvironmentObject var viewModel: Watchlist
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    @State var ticker: String = ""
    
    // State to manage the selected suggestion
    @State private var isselected: Bool = false
    
    var body: some View {
        NavigationStack {
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
                        favView(editMode: $isEditMode)
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
                    .environment(\.editMode, $isEditMode)
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
        .onAppear {
                    viewModel.fetchWatchlist()
                    portfolioViewModel.fetchPortfolio()
                       }
        
    }

}
//
//struct ContentView: View {
//    @State private var isEditMode: EditMode = .inactive
//    @State private var query: String = ""
//    @EnvironmentObject var webService: WebService
//    @EnvironmentObject var viewModel: Watchlist
//    @State private var ticker: String = ""
//    @State private var isselected: Bool = false
//    
//    var body: some View {
//        NavigationView {
//            List {
//                if query.isEmpty {
//                    Section {
//                        headerView()
//                    }
//
//                    Section(header: Text("Portfolio")) {
//                        portfolioHomeView()
//                    }
//                    
//                    Section(header: Text("Favourites")) {
//                        favView(editMode: $isEditMode)
//                    }
//                    .onAppear {
//                        viewModel.fetchWatchlist()
//                    }
//                    
//                    Section {
//                        footerView()
//                    }
//                } else {
//                    ForEach(webService.autocompleteSuggestions) { suggestion in
//                        VStack(alignment: .leading) {
//                            Text(suggestion.displaySymbol).fontWeight(.bold)
//                            Text(suggestion.description).foregroundColor(.gray)
//                        }
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            ticker = suggestion.displaySymbol
//                            webService.fetchAPI(ticker: ticker)
//                            isselected = true
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle("Stocks")
//            .navigationBarItems(trailing: EditButton().environment(\.editMode, $isEditMode))
//            .searchable(text: $query, prompt: "Search")
//            .onChange(of: query) { _ in
//                webService.fetchAutocompleteResults(query: query)
//            }
//            
//            // Link for navigation when a stock is selected from search
//            NavigationLink(destination: StockInfoView(ticker: ticker), isActive: $isselected) {
//                EmptyView()
//            }
//            .hidden()
//        }
//        .onAppear {
//            viewModel.fetchWatchlist()
//        }
//    }
//}



    
    
    
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
    
    // View for the Portfolio section
//    struct portfolioHomeView: View {
//        
//        var netWorth = 25000.00
//        var cashBal = 25000.00
//        
//        var body: some View{
//            VStack(alignment: .leading, spacing: 10) {
//                
//                ZStack{
//                    
//                    
//                    HStack {
//                        // Net Worth
//                        VStack(alignment: .center, spacing: 5) {
//                            Text("Net Worth")
//                                .font(.headline)
//                                .foregroundColor(.black)
//                            Text(Utility.formatCurrency(netWorth))
//                                .font(.body)
//                                .fontWeight(.semibold)
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        
//                        Spacer(minLength: 20)
//                        
//                        // Cash Balance
//                        VStack(alignment: .center, spacing: 5) {
//                            Text("Cash Balance")
//                                .font(.headline)
//                                .foregroundColor(.black)
//                            Text(Utility.formatCurrency(cashBal))
//                                .font(.body)
//                                .fontWeight(.semibold)
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                    }
//                    .padding(.horizontal)
//                    
//                    // Add Stocks in Portfolio and display as list
//                    
//                }.background(Color.white)
//                    .cornerRadius(8)
//                    .padding(.horizontal, -20.0)
//                
//                
//                
//            }
//        }
//        
//    }
    
//    struct favView: View{
//        
//        var body: some View{
//            
//            
//            VStack(alignment: .leading){
//                Text("Favourites")
//                    .font(.subheadline)
//                    .fontWeight(.light)
//                    .foregroundColor(.gray)
//                
//                
//                //ADD LIST OF FAVOURITES
//            }
//        }
//        
//        
//    }
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
    
