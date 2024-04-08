//
//  StockInfo.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/4/24.
//

import SwiftUI
import UIKit



struct StockInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
  
   
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
//                    InsiderSentimentsView()
//                        .listRowSeparator(.hidden)
//                        .listRowBackground(Color.clear)
                    
                    
                    
                    
                }
//                .frame(maxWidth: .infinity, alignment: .leading)
                
                
            }
            
            
            .navigationBarTitle("AAPL")
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
    @State var currentVal = 171.09
    @State var changeVal = -7.58
    @State var changeper = -4.0
    
    var body: some View{
        
        
        VStack(alignment: .leading, spacing: 15){
            
            Text("AAPL Inc")
                .font(.subheadline)
                .foregroundColor(Color.gray)
            
            
            
            HStack(){
                
                Text(Utility.formatCurrency(currentVal))
                    .font(.title)
                    .fontWeight(.semibold)
                
                ZStack{
                    
                    HStack{
                        
                        Image(systemName: (changeVal > 0 ? "arrow.up.forward" : (changeVal < 0 ? "arrow.down.forward" : "minus")))
                        Text(Utility.formatCurrency(changeVal))
                        
                        
                        Text("(\(Utility.formatVal(changeper))%)")
                    }.foregroundColor(changeVal > 0 ? .green : (changeVal < 0 ? .red : .gray))
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
                    Text("You have 0 shares of AAPL.\nStart trading!")
//                        .multilineTextAlignment(.leading)
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

struct StockStats {
    var highPrice: Double
    var openPrice: Double
    var lowPrice: Double
    var previousClose: Double
}



struct StockStatsView: View {
    
    let stockStats = StockStats(highPrice: 177.49, openPrice: 177.00, lowPrice: 170.85, previousClose: 178.67)

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stats")
                .font(.title2)
                .padding(.bottom, 2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("High Price: $\(stockStats.highPrice, specifier: "%.2f")")
                    Text("Low Price: $\(stockStats.lowPrice, specifier: "%.2f")")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Open Price: $\(stockStats.openPrice, specifier: "%.2f")")
                    Text("Prev. Close: $\(stockStats.previousClose, specifier: "%.2f")")
                }
            }
        }
        .padding(.horizontal, -20.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

struct CompanyInfo {
    var ipoStartDate: String
    var industry: String
    var webpage: URL
    var companyPeers: [String]
}

struct CompanyInfoView: View {
    let companyInfo = CompanyInfo(
        ipoStartDate: "1980-12-12",
        industry: "Technology",
        webpage: URL(string: "https://www.apple.com/")!,
        companyPeers: ["AAPL", "DELL", "SMCI", "HPQ", "HPE"]
    )

    var body: some View {
        VStack(alignment: .leading,spacing: 15) {
            Text("About")
                .font(.title2)
                .padding(.bottom, 2)
            VStack(spacing: 7){
                
                
                HStack {
                    Text("IPO Start Date:")
                    Spacer()
                    Text(companyInfo.ipoStartDate)
                }
                
                HStack {
                    Text("Industry:")
                    Spacer()
                    Text(companyInfo.industry)
                }
                
                HStack {
                    Text("Webpage:")
                    Spacer()
                    Link("Apple", destination: companyInfo.webpage)
                }
                
                HStack {
                    Text("Company Peers:")
                    Spacer()
                    ForEach(companyInfo.companyPeers, id: \.self) { peer in
                        Text(peer)
                            .padding(.trailing, 4)
                    }
                }
            }
        }
        .padding(.horizontal, -20.0)
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
    var sentiments = InsiderSentiments(
        mspr: SentimentValues(positive: 200.00, negative: -854.26),
        change: SentimentValues(positive: 200.00, negative: -854.26)
    )

    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Insider Sentiments")
                .font(.title)
                
                
            
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

            
            

            SentimentRow(category: "Total", msprValue: sentiments.mspr.total, changeValue: sentiments.change.total)
            Divider()
            SentimentRow(category: "Positive", msprValue: sentiments.mspr.positive, changeValue: sentiments.change.positive)
            Divider()
            SentimentRow(category: "Negative", msprValue: sentiments.mspr.negative, changeValue: sentiments.change.negative)
            Divider()
        }
        .padding()
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
            Text(String(format: "%.2f", changeValue))
                .frame(width: 80, alignment: .trailing)
        }
        .padding([.top, .bottom], 5)
    }
}



#Preview{
    InsiderSentimentsView()
        
}


#Preview {
    StockInfoView()

}
