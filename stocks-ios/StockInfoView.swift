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
  
   
    @State var selectedChart: ChartType = .hourly
    @State var isAddedtoFav = false
       
    enum ChartType {
           case hourly, historical
       }
    
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .top){
                Color.gray.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                
                List{
                    
                    stockheadView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    
                    if selectedChart == .hourly
                    {
                        HourlyChart
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    } else {
                        HistoricalChart
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    
//                    Spacer().frame(height: 250)
//                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.clear)
                    
                    ChartSwitcherView(selectedChart: $selectedChart)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    
                    PortfView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    StockStatsView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    CompanyInfoView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    InsiderSentimentsView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                   
                    NewsView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    
                    
                    
                }
//                .frame(maxWidth: .infinity, alignment: .leading).listRowBackground(Color.clear) // Set individual row background to transparent
               
                
                
            }
            
            
            .navigationBarTitle(SharedData.shared.ticker)
            .toolbar {
                // Plus button which might perform some action
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddedtoFav.toggle()
                        
                    }) {
                        Image(systemName: isAddedtoFav ? "plus.circle.fill":  "plus.circle")
                            .foregroundColor(.blue) // Style according to your needs
                    }
                }
            }
            
        }
    }
    
    
    
}


struct stockheadView: View{
    @EnvironmentObject var webService: WebService
    var body: some View{
        
        
        VStack(alignment: .leading, spacing: 15){
            
            Text(webService.descData?.name ?? "Loading")
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            
            
            HStack(){
                
                Text(Utility.formatCurrency(webService.stockData?.currentPrice ?? 0))
                    .font(.title)
                    .fontWeight(.semibold)
                
                ZStack{
                    
                    HStack{
                        
                        Image(systemName: (webService.stockData?.Change ?? 0 > 0.01 ? "arrow.up.forward" : (webService.stockData?.Change ?? 0 < 0.01 ? "arrow.down.forward" : "minus")))
                        Text(Utility.formatCurrency(webService.stockData?.Change ?? 0))
                        
                        
                        Text("(\(Utility.formatVal(webService.stockData?.PercentChange ?? 0))%)")
                    }.foregroundColor(webService.stockData?.Change ?? 0 > 0.01 ? .green : (webService.stockData?.Change ?? 0 < 0.01 ? .red : .gray))
                }
                
            }
            
        }
        .padding(.leading, -20.0)
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
        .padding(.leading, 45.0)
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

var HourlyChart: some View {
    
    // Replace with your actual chart view
    Text("Hourly Chart Placeholder")
}

var HistoricalChart: some View {
    
    // Replace with your actual chart view
    Text("Historical Chart Placeholder")
}



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
                        Text("You have 0 shares of \(SharedData.shared.ticker)")
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
        .padding(.horizontal, -20.0)
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
                    Text("High Price: $\(webService.stockData?.high ?? 0, specifier: "%.2f")")
                    Text("Low Price: $\(webService.stockData?.low ?? 0, specifier: "%.2f")")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Open Price: $\(webService.stockData?.open ?? 0, specifier: "%.2f")")
                    Text("Prev. Close: $\(webService.stockData?.previousClose ?? 0, specifier: "%.2f")")
                }
            }
        }
        .padding(.horizontal, -20.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        
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
    //    let companyInfo = CompanyInfo(
    //        ipoStartDate: webService.descData?.ipo ?? "",
    //        industry: "Technology",
    //        webpage: URL(string: "https://www.apple.com/")!,
    //        companyPeers: ["AAPL", "DELL", "SMCI", "HPQ", "HPE"]
    //    )
//    let companyPeers = ["AAPL", "DELL", "SMCI", "HPQ", "HPE"]
    
    var body: some View {
        VStack(alignment: .leading,spacing: 15) {
            Text("About")
                .font(.title2)
                .padding(.bottom, 2)
            VStack(spacing: 7){
                
                
                HStack {
                    Text("IPO Start Date:")
                    Spacer()
                    Text(webService.descData?.ipo ?? "Loading")
                }
                
                HStack {
                    Text("Industry:")
                    Spacer()
                    Text(webService.descData?.finnhubIndustry ?? "Loading")
                }
                
                HStack {
                    Text("Webpage:")
                    Spacer()
                    if let urlString = webService.descData?.weburl, let url = URL(string: urlString) {
                        Link(webService.descData?.weburl ?? "Website", destination: url)
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
                                    SharedData.shared.ticker = peer // Update the shared ticker
                                    webService.fetchAPI()
                                    self.selectedPeer = peer // Trigger navigation
                                }
                                
                                // Invisible NavigationLink for navigation
                                .background(NavigationLink("", destination: StockInfoView(), isActive: .constant(peer == selectedPeer ?? "Loading")).hidden())
                            }
                        }
                    }
                    
                    
                }
            }
        }.padding(.horizontal, -20.0)
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.horizontal, -20.0)
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


#Preview {
    StockInfoView()
        .environmentObject(WebService.service)

}
