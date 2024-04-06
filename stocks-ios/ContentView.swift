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
//
//


struct ContentView: View {
    @State private var isEditMode = false
    @State var ticker = ""
    let currentDate = Date()
    var netWorth = 25000.00
    var cashBal = 25000.00
    let searchController = UISearchController()
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .top) {
                Color.gray.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    // Date View
                    headerView
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    // Portfolio Section
                    portfolioHomeView
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    //Favourites Section
                    favView
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    NavigationLink (destination: StockInfoView(ticker:"AAPL")){
                        Text("Show AAPL")
                    }
                    
                    // Footer View
                    footerView
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    
                }
                
                .navigationBarItems(trailing:
                                Button(action: {
                                    isEditMode.toggle()
                                }) {
                                    Text(isEditMode ? "Done" : "Edit")
                                }
                            )
                
            }
            .navigationBarTitle("Stocks")
        
            .searchable(text: $ticker, prompt: "Search")
//            .onChange(of: searchText) { newValue, _ in
//                print("Search Text: \(newValue)")
//            }
            
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
        }
    }
    
    // Helper to format dates
    
    
    // View for the header with the date
    var headerView: some View {
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
    
    // View for the Portfolio section
    var portfolioHomeView: some View {
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
    
    var favView: some View{
        VStack(alignment: .leading){
            Text("Favourites")
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(.gray)
                
            
            //ADD LIST OF FAVOURITES
            
        }
        
        
    }
    // View for the footer with the Finnhub.io link
    var footerView: some View {
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
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
       
    }
}

