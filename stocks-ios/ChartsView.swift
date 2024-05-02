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
    var htmlContent: String
    @Binding var javascriptString: String?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // Load the initial HTML content
        webView.loadHTMLString(htmlContent, baseURL: nil)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Reload JavaScript if necessary
        if let jsString = javascriptString {
            uiView.evaluateJavaScript(jsString) { result, error in
                if let error = error {
                    print("JavaScript evaluation error after page load: \(error.localizedDescription)")
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ webView: WebView) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let jsString = parent.javascriptString {
                webView.evaluateJavaScript(jsString) { result, error in
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
        WebView(htmlContent: recommendationChartHTML, javascriptString: $javascriptString)
            .onChange(of: webService.recommendationChartDataJson) { newData in
                if let validData = newData {
                    if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        javascriptString = "loadDataForRecomChart(decodeURIComponent('\(encodedData)'));"
                    }
                }
            }
    }

    private var recommendationChartHTML: String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Recommendation Trends Chart</title>
            <script src="https://code.highcharts.com/highcharts.js"></script>
            <script src="https://code.highcharts.com/modules/exporting.js"></script>
        </head>
        <body>
            <div id="recomChartContainer" style="height: 100%; width: 100%; margin: 0 auto;"></div>
            <script>
                // This function will be called from Swift with the JSON data
                function loadDataForRecomChart(jsonData) {
                    // Parse the JSON data
                    try {
                        var dataRecom = JSON.parse(decodeURIComponent(jsonData));
                            // Existing code to update Highcharts chart...
                        } catch (e) {
                            console.error('Error parsing JSON data: ', e);
                            // Handle errors, possibly show an error message in the chart container
                        }

                    // Prepare the data arrays
                    var recomPeriod = [];
                    var strongBuy = [];
                    var buy = [];
                    var hold = [];
                    var sell = [];
                    var strongSell = [];

                    // Populate the data arrays
                    dataRecom.forEach(function(item) {
                        recomPeriod.push(item.period.substring(0, 7));
                        strongBuy.push(item.strongBuy);
                        buy.push(item.buy);
                        hold.push(item.hold);
                        sell.push(item.sell);
                        strongSell.push(item.strongSell);
                    });

                    // Use Highcharts to create the chart
                    Highcharts.chart('recomChartContainer', {
                        chart: { type: 'column' },
                        title: { text: 'Recommendation Trends' },
                        xAxis: { categories: recomPeriod },
                        yAxis: {
                            min: 0,
                            title: { text: '# Analysis', align: 'high' },
                            stackLabels: { enabled: true }
                        },
                        legend: {
                            align: 'center',
                            x: -24,
                            y: 0,
                            backgroundColor: 'white',
                            shadow: false,
                            itemStyle: { fontSize: '7px' },
                        },
                        plotOptions: {
                            column: {
                                stacking: 'normal',
                                dataLabels: { enabled: true }
                            }
                        },
                        series: [
                            { name: 'Strong Buy', data: strongBuy, color: '#186F37' },
                            { name: 'Buy', data: buy, color: '#1CB955' },
                            { name: 'Hold', data: hold, color: '#B98B1D' },
                            { name: 'Sell', data: sell, color: 'rgb(255,0,0)' },
                            { name: 'Strong Sell', data: strongSell, color: '#803131' }
                        ]
                    });
                }
            </script>
        </body>
        </html>

        """
        }
}

struct EPSChartView: View {
    @EnvironmentObject var webService: WebService
    @State private var javascriptString: String? = nil

    var body: some View {
        WebView(htmlContent: epsChartHTML, javascriptString: $javascriptString)
            .onChange(of: webService.EPSChartDataJson) { newData in
                if let validData = newData {
                    if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        javascriptString = "loadEPSChartData(decodeURIComponent('\(encodedData)'));"
                    }
                }
            }
    }

    private var epsChartHTML: String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>EPS Trends Chart</title>
            <script src="https://code.highcharts.com/highcharts.js"></script>
            <script src="https://code.highcharts.com/modules/exporting.js"></script>
        </head>
        <body>
            <div id="epsChartContainer" style="height: 350px; width: 100%; margin: 0 auto;"></div>
            <script>
                function loadEPSChartData(jsonData) {

                    try {
                        var dataEPS = JSON.parse(decodeURIComponent(jsonData));
                            // Existing code to update Highcharts chart...
                        } catch (e) {
                            console.error('Error parsing JSON data: ', e);
                            // Handle errors, possibly show an error message in the chart container
                        }
                    var epsSurpriseDataX = [];
                    var actualData = [];
                    var estimateData = [];
                    
                    dataEPS.forEach(function(item) {
                        var label = item.period + " Surprise: " + item.surprise;
                        epsSurpriseDataX.push(label);
                        actualData.push([label, item.actual]);
                        estimateData.push([label, item.estimate]);
                    });
                    
                    var chartOptionsHistorical = {
                        title: {
                            text: 'Historical EPS Surprises',
                            style: {
                                fontSize: '15px',
                                color: '#29363E',
                            },
                        },
                        yAxis: {
                            title: {
                                text: 'Quarterly EPS',
                            },
                        },
                        xAxis: {
                            type: 'category',
                            categories: epsSurpriseDataX,
                            labels: {
                                rotation: 0,
                                useHTML: true,
                                allowOverlap: true,
                                style: {
                                    fontSize: '10px',
                                    wordBreak: 'break-all',
                                    textAlign: 'center',
                                    textOverflow: 'allow',
                                },
                            },
                        },
                        legend: {
                            layout: 'vertical',
                            align: 'right',
                            verticalAlign: 'middle',
                        },
                        plotOptions: {
                            series: {
                                label: {
                                    connectorAllowed: false,
                                },
                                pointStart: 2010,
                            },
                        },
                        series: [
                            {
                                name: 'Actual',
                                type: 'spline',
                                data: actualData,
                            },
                            {
                                name: 'Estimate',
                                type: 'spline',
                                data: estimateData,
                            },
                        ],
                        responsive: {
                            rules: [
                                {
                                    condition: {
                                        maxWidth: 500,
                                    },
                                    chartOptions: {
                                        legend: {
                                            layout: 'horizontal',
                                            align: 'center',
                                            verticalAlign: 'bottom',
                                        },
                                    },
                                },
                            ],
                        },
                    };
                    
                    Highcharts.chart('epsChartContainer', chartOptionsHistorical);
                }
            </script>
        </body>
        </html>
        """
        }
}

struct HourlyChartView: View {
    @EnvironmentObject var webService: WebService
    @State private var javascriptString: String? = nil

    var body: some View {
        WebView(htmlContent: hourlyChartHTML, javascriptString: $javascriptString)
            .onChange(of: webService.HourlyChartDataJson) { newData in
                if let validData = newData {
                    if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                        javascriptString = "loadHourlyChart(decodeURIComponent('\(encodedData)'), \(webService.stockData.Change));"
                    }
                }
            }
    }

    private var hourlyChartHTML: String {
        """
        <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <script src="https://code.highcharts.com/highcharts.js"></script>
                    <script src="https://code.highcharts.com/modules/exporting.js"></script>
                </head>
                <body>
                    <div id="hourlyChartContainer" style="height: 100%; width: 100%;"></div>
                    <script>
                        function loadHourlyChart(encodedJsonData, change) {
                            try {
                                var jsonData = decodeURIComponent(encodedJsonData);
                                var dataHourly = JSON.parse(jsonData);
                                var list1 = [];

                                dataHourly.results.forEach(function(item) {
                                    var tempList1 = [
                                        item.t, // Timestamp for the X axis
                                        item.c  // Closing price for the Y axis
                                    ];
                                    list1.push(tempList1);
                                });

                                var lineColor = (change > 0) ? '#00ff00' : '#ff0000'; // Green for positive, Red for zero/negative

                                Highcharts.chart('hourlyChartContainer', {
                                    chart: {
                                        type: 'line'
                                    },
                                    title: {
                                        text: dataHourly.ticker + ' Hourly Price Variation',
                                        style: {
                                            color: '#9e9e9f',
                                            fontSize: '15px'
                                        },
                                    },
                                    legend: {
                                        enabled: false
                                    },
                                    yAxis: [{
                                        title: {
                                            text: 'Price ($)'
                                        },
                                        opposite: true
                                    }],
                                    xAxis: {
                                        type: 'datetime',
                                        title: {
                                            text: 'Time'
                                        }
                                    },
                                    series: [{
                                        name: 'Hourly Price',
                                        data: list1,
                                        color: lineColor, // Set the line color based on the change value
                                        marker: {
                                            enabled: false
                                        }
                                    }],
                                    responsive: {
                                        rules: [{
                                            condition: {
                                                maxWidth: 500
                                            },
                                            chartOptions: {
                                                legend: {
                                                    layout: 'horizontal',
                                                    align: 'center',
                                                    verticalAlign: 'bottom'
                                                }
                                            }
                                        }]
                                    }
                                });
                            } catch (e) {
                                console.error('Error parsing JSON data: ', e);
                                document.getElementById('hourlyChartContainer').innerText = 'Error loading data.';
                            }
                        }
                    </script>
                </body>
                </html>
        """
        }
}


    struct HistoricalChartView: View {
        @EnvironmentObject var webService: WebService
        @State private var javascriptString: String? = nil

        var body: some View {
            WebView(htmlContent: historicalChartHTML, javascriptString: $javascriptString)
                .onChange(of: webService.HistoricalChartDataJson) { newData in
                    if let validData = newData {
                        if let encodedData = validData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                            javascriptString = "loadHistoricalChart(decodeURIComponent('\(encodedData)'));"
                        }
                    }
                }
        }

        private var historicalChartHTML: String {
            """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <script src="https://code.highcharts.com/stock/highstock.js"></script>
                <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
            </head>
            <body>
                <div id="historicalChartContainer" style="height: 100%; width: 100%;"></div>

            <script>
                function loadHistoricalChart(jsonData) {
                    try {
                        var data = JSON.parse(decodeURIComponent(jsonData));
                        var ohlc = [];
                        var volume = [];

                        if (!data.results || !data.ticker) {
                            throw new Error("JSON data does not contain required 'results' or 'ticker'");
                        }

                        data.results.forEach(function(item) {
                            ohlc.push([
                                item.t, // time
                                item.o, // open
                                item.h, // high
                                item.l, // low
                                item.c  // close
                            ]);
                            volume.push([
                                item.t, // time
                                item.v  // volume
                            ]);
                        });

                        Highcharts.stockChart('historicalChartContainer', {
                            time: {
                                timezoneOffset: 7 * 60
                            },
                            title: {
                                text: data.ticker + ' Historical'
                            },
                            subtitle: {
                                text: 'With SMA and Volume by Price technical indicators'
                            },
                            rangeSelector: {
                                buttons: [
                                    {type: 'month', count: 1, text: '1m'},
                                    {type: 'month', count: 3, text: '3m'},
                                    {type: 'month', count: 6, text: '6m'},
                                    {type: 'ytd', text: 'YTD'},
                                    {type: 'year', count: 1, text: '1y'},
                                    {type: 'all', text: 'All'}
                                ],
                                selected: 2,
                                inputEnabled: true
                            },
                            xAxis: {
                                type: 'datetime'
                            },
                            yAxis: [
                                {
                                    labels: { align: 'right', x: -3 },
                                    title: { text: 'OHLC' },
                                    height: '60%',
                                    lineWidth: 2,
                                    resize: { enabled: true }
                                },
                                {
                                    labels: { align: 'right', x: -3 },
                                    title: { text: 'Volume' },
                                    top: '65%',
                                    height: '35%',
                                    offset: 0,
                                    lineWidth: 2
                                }
                            ],
                            series: [
                                {
                                    type: 'candlestick',
                                    name: data.ticker,
                                    data: ohlc,
                                    id: data.ticker,
                                    zIndex: 2
                                },
                                {
                                    type: 'column',
                                    name: 'Volume',
                                    data: volume,
                                    yAxis: 1,
                                    id: 'volume'
                                },
                                {
                                    type: 'vbp',
                                    linkedTo: data.ticker,
                                    params: { volumeSeriesID: 'volume' },
                                    dataLabels: { enabled: false },
                                    zoneLines: { enabled: false }
                                },
                                {
                                    type: 'sma',
                                    linkedTo: data.ticker,
                                    zIndex: 1,
                                    marker: { enabled: false }
                                }
                            ]
                        });
                    } catch (e) {
                        console.error('Error parsing JSON data: ', e);
                        document.getElementById('historicalChartContainer').innerText = 'Error loading data. ' + e.message;
                    }
                }
            </script>

            </body>
            </html>

            """
            }
    }

//#Preview {
//    RecomChartView()
//        .environmentObject(WebService.service)
//}
