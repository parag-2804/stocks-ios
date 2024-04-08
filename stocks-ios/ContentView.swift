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


class SharedData: ObservableObject {
    static let shared = SharedData() // Shared instance
    @Published var ticker: String = ""
}




struct ContentView: View {
    @State private var isEditMode = false
    @State private var query: String = ""
    @StateObject var webService = WebService()
    
    // State to manage the selected suggestion
    @State private var isselected: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    // Regular content
                    headerView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    portfolioHomeView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    favView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    NavigationLink(destination: StockInfoView()) {
                        Text("Show AAPL")
                    }
                    footerView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    // Search results
                    ForEach(webService.autocompleteSuggestions) { suggestion in
                        VStack(alignment: .leading) {
                            Text(suggestion.displaySymbol).fontWeight(.bold)
                            Text(suggestion.description).foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isselected = true
                            SharedData.shared.ticker = suggestion.displaySymbol
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Stocks")
            .navigationBarItems(trailing: editButton)
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
    private var editButton: some View {
        Button(action: {
            isEditMode.toggle()
        }) {
            Text(isEditMode ? "Done" : "Edit")
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
                    .padding(.leading, 10.0)
                
            }
            .frame(height: 55)
            .padding(.horizontal, -20.0)
        }
    }
    
    // View for the Portfolio section
    struct portfolioHomeView: View {
        
        var netWorth = 25000.00
        var cashBal = 25000.00
        
        var body: some View{
            VStack(alignment: .leading, spacing: 10) {
                Text("Portfolio")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                
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
                }.background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal, -20.0)
                
                
                // Add Stocks in Portfolio and display as list
            }
        }
        
    }
    
    struct favView: View{
        
        var body: some View{
            
            
            VStack(alignment: .leading){
                Text("Favourites")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                
                
                //ADD LIST OF FAVOURITES
            }
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
            .frame(height: 40)
            .padding(.horizontal, -20.0)
        }
    }
    
    
    // Preview
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            
            ContentView()
            
        }
    }
    
