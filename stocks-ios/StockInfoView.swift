//
//  StockInfo.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/4/24.
//

import SwiftUI
import UIKit
import Kingfisher


struct StockInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var webService: WebService
    @EnvironmentObject var viewModel: Watchlist
    var ticker: String
    @State var selectedChart: ChartType = .hourly
    @State var isAddedtoFav = false
       
    enum ChartType {
           case hourly, historical
       }
    
    var body: some View {
        NavigationStack {
            
            ScrollView{
                
                VStack(alignment: .leading, spacing: 15.0){
                    
                    stockheadView()
                        
                    
                    
                    if selectedChart == .hourly
                    {
                        Text("Hourly Chart")
                        HourlyChartView()
                            .frame(height: 400)
                            
                    } else {
                        Text("Historical Chart")
                        HistoricalChartView()
                            .frame(height: 400)
                           
                    }
                    

                    
                    ChartSwitcherView(selectedChart: $selectedChart)
                      
                    
                    
                    PortfView(ticker: ticker)
                      
                    
                    StockStatsView()
                      
                    
                    CompanyInfoView(ticker: ticker)
                     
                    
                    InsiderSentimentsView()
                     
                    
                    RecomChartView()
                        .frame(height: 400)
                        
                    
                    EPSChartView()
                        .frame(height: 400)
                      
                   
                    NewsView()
                       
                    
                    
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)

               
                
                
            }
            .padding(.horizontal, 15.0)
            
            
            .navigationBarTitle(ticker)
            .toolbar {
                // Plus button which might perform some action
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.addStockToWatchlist(symbol: ticker, companyName: webService.descData.name)
                        isAddedtoFav.toggle()
                        
                        
                    }) {
                        Image(systemName: isAddedtoFav ? "plus.circle.fill":  "plus.circle")
                            .foregroundColor(.blue) // Style according to your needs
                    }
                }
            }
            .onAppear {
                        /*webService.fetchAPI(ticker: ticker)
                         */  // Fetching data when the view appears
                webService.fetchAPI(ticker: ticker)
                    }
        }
      
    }
    
  
    
}


struct stockheadView: View{
    @EnvironmentObject var webService: WebService
    var body: some View{
        
        
        VStack(alignment: .leading, spacing: 15){
            
            HStack{
                
                Text(webService.descData.name)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                Spacer()
                let imageUrl = URL(string: webService.descData.logo)
                    KFImage(imageUrl)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
//                        .clipped()
//                        .cornerRadius(8)
            }
            
            
            
            HStack(){
                
                Text(Utility.formatCurrency(webService.stockData.currentPrice))
                    .font(.title)
                    .fontWeight(.semibold)
//                Spacer()
                ZStack{
                    
                    HStack {
                        Image(systemName: webService.stockData.Change > 0 ? "arrow.up.forward" : (webService.stockData.Change < 0 ? "arrow.down.forward" : "minus"))
                        Text(Utility.formatCurrency(webService.stockData.Change))
                        Text("(\(Utility.formatVal(webService.stockData.PercentChange))%)")
                    }.foregroundColor(webService.stockData.Change > 0 ? .green : (webService.stockData.Change < 0 ? .red : .gray))

                }
                
            }
            
        }
       
        .padding(.top, 10.0)
    }
    }


struct ChartSwitcherView: View {
    @Binding var selectedChart: StockInfoView.ChartType

    var body: some View {
        HStack {
            Button(action: {
                self.selectedChart = .hourly
            }) {
                ChartLabel(title: "Hourly", icon: "chart.xyaxis.line", isSelected: selectedChart == .hourly)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer().frame(width: 100)
            
            Button(action: {
                self.selectedChart = .historical
            }) {
                ChartLabel(title: "Historical", icon: "clock", isSelected: selectedChart == .historical)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.leading, 85.0)
    }
}

// Custom label for the chart switcher buttons
struct ChartLabel: View {
    var title: String
    var icon: String
    var isSelected: Bool

    var body: some View {
        Label {
            Text(title)
                .foregroundColor(isSelected ? .blue : .gray)
        } icon: {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .labelStyle(VerticalLabelStyle())
    }
}

//var HourlyChart: some View {
//    
//    // Replace with your actual chart view
//    Text("Hourly Chart Placeholder")
//    HourlyChartView()
//}
//
//var HistoricalChart: some View {
//    
//    // Replace with your actual chart view
//    Text("Historical Chart Placeholder")
//}



struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}


struct PortfView: View {
    @State var stockOwned: Bool = false
    @State var sharesOwned: Int = 0
    @State var avgCostPerShare: Double = 0.0
    @State var totalCost: Double = 0.0
    @State var marketValue: Double = 0.0
    var ticker: String
    var body: some View {
        
        HStack(spacing: 45.0) {
            
            VStack(alignment: .leading, spacing: 15.0){
                Text("Portfolio")
                    .font(.title2)
                //                .padding()
                
                if stockOwned {
                    VStack {
                        HStack {
                            Text("Shares Owned:")
                            Spacer()
                            Text("\(sharesOwned)")
                        }
                        HStack {
                            Text("Avg. Cost / Share:")
                            Spacer()
                            Text("$\(avgCostPerShare, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Total Cost:")
                            Spacer()
                            Text("$\(totalCost, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Change:")
                            Spacer()
                            // Assuming you calculate the change elsewhere and set it
                            Text("$\(marketValue - totalCost, specifier: "%.2f")")
                                .foregroundColor(marketValue - totalCost < 0 ? .red : .green)
                        }
                        HStack {
                            Text("Market Value:")
                            Spacer()
                            Text("$\(marketValue, specifier: "%.2f")")
                        }
                    }
                } else {
                    VStack(alignment: .leading){
                        Text("You have 0 shares of \(ticker)")
                        Text("Start trading!")
                            
                    }
                   
                }
                
            }
            
            Button(action: {
                // Actions to perform when trade button is pressed
            }) {
                Text("Trade")
                    .padding()
                    .frame(maxWidth: 150)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding()
        }

    }
    
}

//struct StockStats {
//    var highPrice: Double
//    var openPrice: Double
//    var lowPrice: Double
//    var previousClose: Double
//}



struct StockStatsView: View {
    @EnvironmentObject var webService: WebService

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stats")
                .font(.title2)
                .padding(.bottom, 2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("High Price: $\(webService.stockData.high, specifier: "%.2f")")
                    Text("Low Price: $\(webService.stockData.low, specifier: "%.2f")")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Open Price: $\(webService.stockData.open, specifier: "%.2f")")
                    Text("Prev. Close: $\(webService.stockData.previousClose, specifier: "%.2f")")
                }
            }
        }
      
        
        
    }
}

//struct CompanyInfo {
//    var ipoStartDate: String
//    var industry: String
//    var webpage: URL
//    var companyPeers: [String]
//}

struct CompanyInfoView: View {
    @EnvironmentObject var webService: WebService
    @State private var selectedPeer: String? = nil
    @State var ticker: String
    
    var body: some View {
        VStack(alignment: .leading,spacing: 15) {
            Text("About")
                .font(.title2)
                .padding(.bottom, 2)
            VStack(spacing: 7){
                
                
                HStack {
                    Text("IPO Start Date:")
                    Spacer()
                    Text(webService.descData.ipo)
                }
                
                HStack {
                    Text("Industry:")
                    Spacer()
                    Text(webService.descData.finnhubIndustry)
                }
                
                HStack {
                    Text("Webpage:")
                    Spacer()
                    let urlString = webService.descData.weburl
                        if let url = URL(string: urlString) {
                        Link(webService.descData.weburl, destination: url)
                    } else {
                        // Handle case where URL is not valid or missing
                        Text("Loading")
                    }
                }
                
                HStack {
                    Text("Company Peers:")
                    Spacer()
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(webService.peers, id: \.self) { peer in
                                Text(peer)
                                    .foregroundColor(.blue) // Set the text color to blue for a link-like appearance
                                    .onTapGesture {
                                        ticker = peer // Update the shared ticker
                                        webService.fetchAPI(ticker: ticker)
                                    self.selectedPeer = peer // Trigger navigation
                                }
                                
                                // Invisible NavigationLink for navigation
                                    .background(NavigationLink("", destination: StockInfoView(ticker: ticker), isActive: .constant(peer == selectedPeer ?? "Loading")).hidden())
                            }
                        }
                    }
                    
                    
                }
            }
        }
           
    }
}
    
struct SentimentValues {
    var positive: Double
    var negative: Double

    // Computed property for total
    var total: Double {
        return positive + negative
    }
}

// Define the data structure for the Insider Sentiments
struct InsiderSentiments {
    var mspr: SentimentValues
    var change: SentimentValues
}
struct InsiderSentimentsView: View {
    @EnvironmentObject var webService: WebService
    
 

    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Insider Sentiments")
                .font(.title2)
                
                
            
             HStack {
                        Text("Category")
                            .bold()
                        Spacer()
                        Text("MSPR")
                            .bold()
                        Spacer()
                        Text("Change")
                            .bold()
                    }
             .padding(.vertical, 10.0)

            
            
            Divider()
            SentimentRow(category: "Total", msprValue: (webService.insiderSums.positiveMsprSum + webService.insiderSums.negativeMsprSum), changeValue: Double((webService.insiderSums.positiveChangeSum + webService.insiderSums.negativeChangeSum)))
            Divider()
            SentimentRow(category: "Positive", msprValue: webService.insiderSums.positiveMsprSum, changeValue: Double(webService.insiderSums.positiveChangeSum))
            Divider()
            SentimentRow(category: "Negative", msprValue: webService.insiderSums.negativeMsprSum, changeValue: Double(webService.insiderSums.negativeChangeSum))
            Divider()
        }
        
    }
}

// Define a view for a single row in the table with MSPR and Change values
struct SentimentRow: View {
    let category: String
    let msprValue: Double
    let changeValue: Double

    var body: some View {
        
        
        HStack {
            Text(category)
                .fontWeight(.bold)
                .frame(width: 80, alignment: .leading)
            Spacer()
            Text(String(format: "%.2f", msprValue))
                .frame(width: 80, alignment: .trailing)
            Spacer()
            Text(String(format: "%0.f", changeValue))
                .frame(width: 80, alignment: .trailing)
        }
        .padding([.top, .bottom], 5)
    }
}











//#Preview{
//   InsiderSentimentsView()
//        .environmentObject(WebService.service)
//        
//}

//
//#Preview {
//    StockInfoView(ticker: ticker)
//        .environmentObject(WebService.service)
//        .environmentObject(Watchlist())
//
//}
