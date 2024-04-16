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

//    func makeUIView(context: Context) -> WKWebView {
//        guard let filePath = Bundle.main.path(forResource: htmlName, ofType: "html") else {
//            fatalError("File not found.")
//        }
//        let fileURL = URL(fileURLWithPath: filePath)
//        let request = URLRequest(url: fileURL)
//
//        let webView = WKWebView()
//        webView.load(request)
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        if let javascript = javascriptString {
//            uiView.evaluateJavaScript(javascript) { result, error in
//                if let error = error {
//                    print("JavaScript evaluation error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator
//        if let filePath = Bundle.main.path(forResource: htmlName, ofType: "html"),
//           let fileURL = URL(string: filePath) {
//            let request = URLRequest(url: fileURL)
//            webView.load(request)
//        }
//        return webView
//    }
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
                        // Safely encode the JSON string for URL
                        if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                            // Pass the safely encoded JSON string to the JavaScript function
                            javascriptString = "loadHistoricalChart(decodeURIComponent('\(encodedData)'));"
                        }
                    }
                }
    }
    
}

#Preview {
    RecomChartView()
        .environmentObject(WebService.service)
}
