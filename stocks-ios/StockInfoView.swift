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
//    @State var selectedChart: ChartType = .hourly
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    @State var isAddedtoFav = false
    @State private var isLoading: Bool = true
    enum ChartType {
           case hourly, historical
       }
    
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
                
                ScrollView{
                    
                    VStack(alignment: .leading, spacing: 25.0){
                        
                        stockheadView()
                        

                        TabView {
                            HourlyChartView()
                                .tabItem {
                                    Image(systemName: "chart.xyaxis.line")
                                    Text("Hourly")
                                }
                            
                            HistoricalChartView()
                                .tabItem {
                                    Image(systemName: "clock")
                                    Text("Historical")
                                }
                        }
                        .frame(height: 500)
                        
                        
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
                            if isAddedtoFav {
                                // If the stock is already added, delete it from the watchlist
                                viewModel.deleteStockFromWatchlist(symbol: ticker)
                            } else {
                                viewModel.addStockToWatchlist(symbol: ticker, companyName: webService.descData.name)
                                
                                toastMessage = "Adding \(ticker) to Favourites"
                                showToast = true
                            }
                            isAddedtoFav.toggle()
                            
                            
                        }) {
                            Image(systemName: isAddedtoFav ? "plus.circle.fill":  "plus.circle")
                                .foregroundColor(.blue) // Style according to your needs
                        }
                    }
                }
                .onAppear {
                    portfolioViewModel.fetchPortfolio()
                    /*webService.fetchAPI(ticker: ticker)
                     */  // Fetching data when the view appears
                    isAddedtoFav = viewModel.stocks.contains { $0.symbol == ticker }
                    webService.fetchAPI(ticker: ticker)
                }
            }
        }
        .toast(message: toastMessage ,isShowing: $showToast)
      
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
                        .frame(width: 50, height: 50)
//                        .clipped()
                        .cornerRadius(12)
            }
            
            
            
            HStack(spacing: 15){
                
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





struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}


struct PortfView: View {
    
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    @State private var showTradeSheet = false
    var ticker: String
    
    private var stockDetails: Stock? {
            portfolioViewModel.portfolioData?.stocklist.first(where: { $0.symbol == ticker })
        
        }
        
        private var stockOwned: Bool {
            stockDetails != nil && stockDetails?.quantity ?? 0 > 0
        }
        
        private var sharesOwned: Int {
            stockDetails?.quantity ?? 0
        }
        
        private var avgCostPerShare: Double {
            stockDetails?.buyPrice ?? 0
        }
        
        private var totalCost: Double {
            avgCostPerShare * Double(sharesOwned)
        }
        
        private var marketValue: Double {
            stockDetails?.marketValue ?? 0
        }
        
        private var changeInValue: Double {
            stockDetails?.changeInPrice ?? 0
        }
    var body: some View {
        
        HStack(spacing: 45.0) {
            
            VStack(alignment: .leading, spacing: 15.0){
                Text("Portfolio")
                    .font(.title2)
                    
                //                .padding()
                
                if stockOwned {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Shares Owned:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(sharesOwned)")
                                .font(.caption)
                        }
                        HStack {
                            Text("Avg. Cost / Share:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(avgCostPerShare, specifier: "%.2f")")
                                .font(.caption)
                        }
                        HStack {
                            Text("Total Cost:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(totalCost, specifier: "%.2f")")
                                .font(.caption)
                        }
                        HStack {
                            Text("Change:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            // Assuming you calculate the change elsewhere and set it
                            Text("$\(marketValue - totalCost, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(marketValue - totalCost < 0 ? .red : marketValue - totalCost > 0 ? .green : .gray)
                        }
                        HStack {
                            Text("Market Value:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(marketValue, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(marketValue - totalCost < 0 ? .red : marketValue - totalCost > 0 ? .green : .gray)
                        }
                    }
                    
                } else {
                    VStack(alignment: .leading){
                        Text("You have 0 shares of \(ticker)")
                            .font(.caption)
                        Text("Start trading!")
                            .font(.caption)
                            
                    }
                   
                }
                
            }
            
            Button(action: {
                
                self.showTradeSheet = true
//                portfolioViewModel.fetchPortfolio()
                
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
            .sheet(isPresented: $showTradeSheet) {
                TradeSheetView( isPresented: $showTradeSheet, ticker: ticker)
                    }
        }

    }
    
}

struct Toast: ViewModifier {
    let message: String
    @Binding var isShowing: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if isShowing {
                Text(message)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(40)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.isShowing = false
                            }
                        }
                    }
                .zIndex(1)
            }
        }
    }
}

extension View {
    func toast(message: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(Toast(message: message, isShowing: isShowing))
    }
}





struct SuccessView: View {
    let tradeType: String
    let numberOfShares: Int
    let stockSymbol: String
    var dismissAction: () -> Void
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
//    enum TradeType {
//        case buy, sell
//    }

    var body: some View {
        ZStack {
            // Use green color for the full background
            Color.green.edgesIgnoringSafeArea(.all)

            // Use VStack for the message and button
            VStack(spacing: 15) {
                Spacer()
                
                Text("Congratulations!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("You have successfully \(tradeType) \(numberOfShares) \(numberOfShares == 1 ? "share" : "shares") of \(stockSymbol).")
                    .font(.body)
                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5.0)

                Spacer()
                
//                Button(action: dismissAction)
                Button(action: {
                            portfolioViewModel.fetchPortfolio() // Fetch portfolio data
                            dismissAction()                     // Dismiss the view
                        })
                {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(30)
                }
                .padding()
            }
        }
    }
}



struct TradeSheetView: View {
    
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @EnvironmentObject var webService: WebService
    @Binding var isPresented: Bool
    
    @State private var numberOfShares: String = ""
    var ticker: String
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showSuccessPopup = false
    @State var tradeType: String = ""
   
    private var stockDetails: Stock? {
            portfolioViewModel.portfolioData?.stocklist.first(where: { $0.symbol == ticker })
        }
    
    private var stockOwned: Bool {
        stockDetails != nil && stockDetails?.quantity ?? 0 > 0
    }
    
    private var sharesOwned: Int {
        stockDetails?.quantity ?? 0
    }
//    private var currentBuyPrice: Double {
//        stockDetails?.latestQuote ?? 0
//    }
    private var currentBuyPrice: Double {
        stockDetails?.latestQuote ?? 0 != 0 ? stockDetails?.latestQuote ?? 0 : webService.stockData.currentPrice
    }
    
    private var totalCost: Double {
            (Double(numberOfShares) ?? 0) * currentBuyPrice
        }
    
    
    private func executeBuyTrade() {
        if(Int(numberOfShares) == nil)
        {
               toastMessage = "Please enter a valid amount"
               showToast  = true
               return
        }
        
        else if(Int(numberOfShares) ?? 0 < 1){
               toastMessage = "Cannot buy non-positive shares"
               showToast = true
                return
            }
        
            let availableFunds = portfolioViewModel.portfolioData?.balance ?? 0
            if totalCost > availableFunds {
                toastMessage = "Not enough money to buy"
                showToast = true
               
                return
            }
        
        else{
            
            portfolioViewModel.buyStock(symbol: ticker, name: webService.descData.name, quantity: sharesOwned + (Int(numberOfShares) ?? 0), buyPrice: currentBuyPrice, stockPresent: stockOwned, balance: Double((availableFunds - totalCost)))
//            tradeType = .buy
            showSuccessPopup = true
//            self.isPresented = false
//            portfolioViewModel.fetchPortfolio()
            
            //Show Congratulations View for tradetype = .buy
        }
        
        
}

    
    private func executeSellTrade() {
        if(Int(numberOfShares) == nil)
        {
                       toastMessage = "Please enter a valid amount"
                       showToast  = true
                       return
        }
        
        else if(Int(numberOfShares) ?? 0 < 1){
               toastMessage = "Cannot sell non-positive shares"
               showToast = true
                return
            }

        
        if Int(numberOfShares) ?? 0 > sharesOwned {
                toastMessage = "Not enough shares to sell"
                showToast = true
                
                return
            }
        
        else{
            print("Updated Balance: \(portfolioViewModel.portfolioData?.balance ?? 0 + totalCost)")
            portfolioViewModel.sellStock(symbol: ticker,quantity: (sharesOwned - (Int(numberOfShares) ?? 0)), newPrice: currentBuyPrice, balance: ((portfolioViewModel.portfolioData?.balance ?? 0 ) + totalCost))
            
//            tradeType = .sell
            showSuccessPopup = true
//            self.isPresented = false
//            portfolioViewModel.fetchPortfolio()
            
            //Show Congratulations View
        }
        
        
}
    

    
    var body: some View {
        
        if(showSuccessPopup){
            SuccessView(tradeType: tradeType, numberOfShares: Int(numberOfShares) ?? 0, stockSymbol: ticker, dismissAction: {
                            // This closure will be called when the "Done" button is tapped
                            self.isPresented = false
                            showSuccessPopup = false
            
                        })
        }
        else{
            NavigationView{
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.isPresented = false
                        }) {
                            Image(systemName: "xmark")
                        }
                        .padding()
                    }
                    
                    Text("Trade \(webService.descData.name) shares")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    HStack(){
                        TextField("0", text: $numberOfShares)
                        
                            .keyboardType(.numberPad)
                            .font(.system(size: 100))
                        
                        //                        .multilineTextAlignment(.center)
                            .onChange(of: numberOfShares) { _ in
                                
                                
                                //                            portfolioViewModel.fetchPortfolio()
                            }
                        
                        
                        Text((Int(numberOfShares) == 1 || Int(numberOfShares) == 0 ? "Share" : "Shares"))
                            .font(.title)
                    }
                    .padding(.horizontal, 15.0)
                    HStack{
                        Spacer()
                        Text("× $\(webService.stockData.currentPrice, specifier: "%.2f")/share = $\(totalCost,specifier: "%.2f")")
                            .padding()
                    }
                    Spacer()
                    Text("$\(portfolioViewModel.portfolioData?.balance ?? 0, specifier: "%.2f") available to buy \(ticker)")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    
                    HStack {
                        Button(action: {
                            
                            //                        tradeType = .buy
                            
                            tradeType = "bought"
                            executeBuyTrade()
                            //                        self.isPresented = false
                            
                        }) {
                            Text("Buy")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                        
                        Button(action: {
                            tradeType = "sold"
                            executeSellTrade()
                            //                        self.isPresented = false
                            
                        }) {
                            Text("Sell")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                    .padding()
                }
            }
            
            .toast(message: toastMessage ,isShowing: $showToast)
            //        .sheet(isPresented: $showSuccessPopup){
            //        //        .sheet(isPresented: $showSuccessPopup)
            //
            //            SuccessView(tradeType: tradeType, numberOfShares: Int(numberOfShares) ?? 0, stockSymbol: ticker, dismissAction: {
            //                // This closure will be called when the "Done" button is tapped
            //                self.isPresented = false
            //                showSuccessPopup = false
            //
            //            })
            //        }
            
        }
    }
}



struct StockStatsView: View {
    @EnvironmentObject var webService: WebService

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stats")
                .font(.title2)
                .padding(.bottom, 2)
            
            HStack(spacing: 40) {
                VStack(alignment: .leading) {
                    HStack{
                        Text("High Price: ")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("$\(webService.stockData.high, specifier: "%.2f")")
                            .font(.caption)
                    }
//                      .fontWeight(.semibold)
                    
                    HStack{
                        Text("Low Price: ")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("$\(webService.stockData.low, specifier: "%.2f")")
                            .font(.caption)
                    }
                }
                
//                Spacer()
                
                VStack(alignment: .leading) {
                    
                    HStack{
                        
                        Text("Open Price: ")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("$\(webService.stockData.open, specifier: "%.2f")")
                            .font(.caption)
                    }
                    HStack{
                        Text("Prev. Close: ")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("$\(webService.stockData.previousClose, specifier: "%.2f")")
                            .font(.caption)
                    }
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
            
            HStack(spacing: 60){
                
            
                VStack(alignment: .leading, spacing: 10){
                    
                    

                    Text("IPO Start Date:")
                        .font(.caption)
                            .fontWeight(.semibold)


                    Text("Industry:")
                        .font(.caption)
                            .fontWeight(.semibold)

                    

                    Text("Webpage:")
                        .font(.caption)
                            .fontWeight(.semibold)

                    Text("Company Peers:")
                        .font(.caption)
                            .fontWeight(.semibold)

                }
                
                VStack(alignment: .leading, spacing: 10){
                    
                    
                    Text(webService.descData.ipo)
                        .font(.caption)
                    
                    
                    Text(webService.descData.finnhubIndustry)
                        .font(.caption)
                    
                    
                    
                    let urlString = webService.descData.weburl
                    if let url = URL(string: urlString) {
                        Link(webService.descData.weburl, destination: url)
                            .font(.caption)
                    } else {
                        // Handle case where URL is not valid or missing
                        Text("Loading")
                            .font(.caption)
                    }
                    
                    
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(webService.peers, id: \.self) { peer in
                                Text(peer)
                                    .font(.caption)
                                
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
            
            Text("Insights")
                .font(.title2)
            
            Text("Insider Sentiments")
                .font(.title2)
                .padding(.leading, 102.0)
                .padding(.top, 10.0)
//                .multilineTextAlignment(.center)
            
                
                
            
             HStack {
                 Text(webService.descData.name)
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


//struct StockInfoViewView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        StockInfoView(ticker: "AAPL")
//            .environmentObject(WebService.service)
//            .environmentObject(Watchlist())
//            .environmentObject(PortfolioViewModel())
//        
//    }
//}







