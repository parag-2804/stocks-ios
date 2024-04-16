////
////  ContentView.swift
////  stocks-ios
////
////  Created by Parag Jadhav on 4/3/24.
////
//
import SwiftUI
import UIKit




class SharedData: ObservableObject {
    static let shared = SharedData() // Shared instance
    @Published var ticker: String = "AAPL"
}




struct ContentView: View {
    @State private var isEditMode: EditMode = .inactive
    @State private var query: String = ""
//    @StateObject var webService = WebService()
    @EnvironmentObject var webService: WebService
    @EnvironmentObject var viewModel: Watchlist
    
    // State to manage the selected suggestion
    @State private var isselected: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    
                    Section{
                        headerView()
                    }

                    Section(header: Text("Portfolio")){
                        portfolioHomeView()
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
                            
                            SharedData.shared.ticker = suggestion.displaySymbol
                            webService.fetchAPI()
                            isselected = true
                        }
                    }
                }
            }

            .navigationBarTitle("Stocks")
            .toolbar{
                EditButton()
            }
//            .navigationBarItems(trailing: editButton)
            .searchable(text: $query, prompt: "Search")
            .onChange(of: query) { _ in
                webService.fetchAutocompleteResults(query: query)
            }
            NavigationLink(destination: StockInfoView(), isActive: $isselected) {
                EmptyView()
            }
            .hidden()
            
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
    
    // View for the Portfolio section
    struct portfolioHomeView: View {
        
        var netWorth = 25000.00
        var cashBal = 25000.00
        
        var body: some View{
            VStack(alignment: .leading, spacing: 10) {
                
                ZStack{
                    
                    
                    HStack {
                        // Net Worth
                        VStack(alignment: .center, spacing: 5) {
                            Text("Net Worth")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(Utility.formatCurrency(netWorth))
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        
                        Spacer(minLength: 20)
                        
                        // Cash Balance
                        VStack(alignment: .center, spacing: 5) {
                            Text("Cash Balance")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(Utility.formatCurrency(cashBal))
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Add Stocks in Portfolio and display as list
                    
                }.background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal, -20.0)
                
                
                
            }
        }
        
    }
    
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
            
        }
    }
    
