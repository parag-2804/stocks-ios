//
//  ChartsView.swift
//  stocks-ios
//
//  Created by Parag Jadhav on 4/12/24.
//

import SwiftUI
import WebKit
import UIKit
import Combine
import Foundation

struct WebView: UIViewRepresentable {
    var htmlName: String
    @Binding var javascriptString: String?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let filePath = Bundle.main.path(forResource: htmlName, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            let request = URLRequest(url: fileURL)
            webView.load(request)
        } else {
            print("Failed to locate \(htmlName).html in bundle.")
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ webView: WebView) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let javascript = parent.javascriptString {
                webView.evaluateJavaScript(javascript) { result, error in
                    if let error = error {
                        print("JavaScript evaluation error after page load: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


struct RecomChartView: View {
    @EnvironmentObject var webService: WebService
    @State private var javascriptString: String? = nil

    var body: some View {
        
            WebView(htmlName: "recommendationChart", javascriptString: $javascriptString)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
            //            .onAppear {
            //                webService.fetchRecommendationChartData()
            //            }
            //            .onChange(of: webService.recommendationChartDataJson) { newData in
            //                if let validData = newData {
            //                    let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            //                    javascriptString = "loadDataForRecomChart(decodeURIComponent('\(encodedData ?? "")'));"
            //                }
            //            }
            //
            //            .onChange(of: webService.recommendationChartDataJson) { newData in
            //                if let validData = newData {
            //                    print("Recommendation Chart JSON: \(validData)")
            //                    javascriptString = "loadDataForRecomChart(\(validData));"
            //                }
            //            }
                .onChange(of: webService.recommendationChartDataJson) { newData in
                    if let validData = newData {
                        // Safely encode the JSON string for URL
                        if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                            // Pass the safely encoded JSON string to the JavaScript function
                            javascriptString = "loadDataForRecomChart(decodeURIComponent('\(encodedData)'));"
                        }
                    }
                }
        }
    
}

struct EPSChartView: View {
    @EnvironmentObject var webService: WebService
    @State private var javascriptString: String? = nil

    var body: some View {
            
            WebView(htmlName: "EPSChart", javascriptString: $javascriptString)
            
                .onChange(of: webService.EPSChartDataJson) { newData in
                    if let validData = newData {
                        // Safely encode the JSON string for URL
                        if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                            // Pass the safely encoded JSON string to the JavaScript function
                            javascriptString = "loadEPSChartData(decodeURIComponent('\(encodedData)'));"
                        }
                    }
                }
    }
    
}

struct HourlyChartView: View {
    @EnvironmentObject var webService: WebService
    @State private var javascriptString: String? = nil

    var body: some View {
            
            WebView(htmlName: "HourlyChart", javascriptString: $javascriptString)
            
            .onChange(of: webService.HourlyChartDataJson) { newData in
                if let validData = newData {
//                    print("Hourly Chart Data: \(newData)")
//                    print("Hourly Chart Json passed:\(validData)")
                    // Safely encode the JSON string for URL
                    if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                        // Pass the safely encoded JSON string to the JavaScript function
//                        print("Hourly Chart Json passed:\(encodedData)")
                        javascriptString = "loadHourlyChart(decodeURIComponent('\(encodedData)'));"
                    }
                }
            }
    }
    
}

struct HistoricalChartView: View {
    @EnvironmentObject var webService: WebService
    @State private var javascriptString: String? = nil

    var body: some View {
            
            WebView(htmlName: "HistoricalChart", javascriptString: $javascriptString)
            
                .onChange(of: webService.HistoricalChartDataJson) { newData in
                    if let validData = newData {
                        
                        print("Historical Chart Data: \(newData)")
                        // Safely encode the JSON string for URL
                        if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                            // Pass the safely encoded JSON string to the JavaScript function
                            javascriptString = "loadHistoricalChart(decodeURIComponent('\(encodedData)'));"
                        }
                    }
                }
    }
    
}



//struct HistoricalChartView: View {
//    //@ObservedObject var viewModel: HistoricalChartViewModel
//    @EnvironmentObject var viewModel: WebService
//
//    var body: some View {
//        Group {
////            if viewModel.isLoading {
////                ProgressView("Loading...")
////            } else
//            if let errorMessage = viewModel.errorMessage {
//                Text(errorMessage)
//            } else {
//                HistoricalChartWebView(chartData: viewModel.historicalData)
//                    .frame(height: 400)
//            }
//        }
//
//    }
//}

//struct HistoricalChartWebView: UIViewRepresentable {
//    let chartData: [HistoricalStockPoint]
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//        return webView
//    }
//    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // Prepare the data strings
//        let ohlcDataString = chartData.map { "[\($0.t), \($0.o), \($0.h), \($0.l), \($0.c)]" }.joined(separator: ", ")
//        let volumeDataString = chartData.map { "[\($0.t), \($0.v)]" }.joined(separator: ", ")
//        
//        let htmlContent = generateHistoricalChartHTML(ohlcDataString: ohlcDataString, volumeDataString: volumeDataString, title: "Dynamic Symbol")
//        uiView.loadHTMLString(htmlContent, baseURL: nil)
//    }
//
//    
//    private func generateHistoricalChartHTML(ohlcDataString: String, volumeDataString: String, title: String) -> String {
//        let htmlContent = """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta name="viewport" content="width=device-width, initial-scale=1">
//            <script src="https://code.highcharts.com/stock/highstock.js"></script>
//            <script src="https://code.highcharts.com/stock/modules/data.js"></script>
//            <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
//            <script src="https://code.highcharts.com/stock/modules/accessibility.js"></script>
//            <style>
//                html, body, #container { height: 100%; margin: 0; padding: 0; }
//            </style>
//        </head>
//        <body>
//            <div id="container"></div>
//            <script>
//                console.log('OHLC data:', [\(ohlcDataString)]);
//                console.log('Volume data:', [\(volumeDataString)]);
//                Highcharts.stockChart('container', {
//                    chart: {
//                        zoomType: 'x'
//                    },
//                    title: {
//                        text: 'Historical',
//                        style: {
//                            fontSize: '15'
//                        }
//                    },
//                    subtitle: {
//                        text: 'With SMA and Volume by Price technical indicators',
//                        style: {
//                            color: '#9e9e9f',
//                            fontSize: '12'
//                        }
//                    },
//                    rangeSelector: {
//                        selected: 4, // This will select the '1y' button by default to zoom closer on the most recent data
//                        inputEnabled: false, // Disables the input boxes
//                        buttons: [{
//                            type: 'month',
//                            count: 1,
//                            text: '1m'
//                        }, {
//                            type: 'month',
//                            count: 3,
//                            text: '3m'
//                        }, {
//                            type: 'month',
//                            count: 6,
//                            text: '6m'
//                        },{
//                            type: 'year',
//                            count: 1,
//                            text: '1y'
//                        }, {
//                            type: 'all',
//                            text: 'All'
//                        }]
//                    },
//                    xAxis: {
//                        type: 'datetime',
//                        ordinal: false // This makes sure that periods without data are not displayed
//                    },
//                    yAxis: [{
//                        labels: {
//                            align: 'right',
//                            x: -3
//                        },
//                        title: {
//                            text: 'OHLC'
//                        },
//                        height: '60%',
//                        lineWidth: 2,
//                        resize: {
//                            enabled: true
//                        }
//                    }, {
//                        labels: {
//                            align: 'right',
//                            x: -3
//                        },
//                        title: {
//                            text: 'Volume'
//                        },
//                        top: '65%',
//                        height: '35%',
//                        offset: 0,
//                        lineWidth: 2
//                    }],
//                    tooltip: {
//                        split: true
//                    },
//                    series: [{
//                        type: 'candlestick',
//                        name: '\(title)',
//                        data: [\(ohlcDataString)],
//                        zIndex: 2
//                    }, {
//                        type: 'column',
//                        name: 'Volume',
//                        data: [\(volumeDataString)],
//                        yAxis: 1
//                    }]
//                });
//            </script>
//        </body>
//        </html>
//        """
//        return htmlContent
//    }
//
//}

#Preview {
    RecomChartView()
        .environmentObject(WebService.service)
}
