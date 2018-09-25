//
//  ExchangeRateForChartsParser.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 11.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import Charts

class ExchangeRatesForChartsParser {
    
    struct Rate {
        let value : Double
        let time : String
    }
    
    public class func parse(lineChartView : LineChartView, urlString : String, crypto : String, fiat : String) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var result : [Rate] = [Rate]()
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                
                if let rates = json["Data"] as? [[String: Any]] {
                    for rate in rates {
                        let timeChart = Utils.formatDateTime(timestamp: Int64(rate["time"] as! Int), format24h: false)
                        print(timeChart)
                        result.append(Rate(value: rate["close"] as? Double ?? Double(rate["close"] as! Int), time: timeChart))
                    }
                }

                updateCharts(lineChartView: lineChartView, arrayRates: result, crypto: crypto, fiat: fiat)
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
        }.resume()
    }
    
    class func updateCharts(lineChartView : LineChartView, arrayRates : [Rate], crypto : String, fiat : String) {

        let data = LineChartData()

        var dataEntries: [ChartDataEntry] = []
        var dates = [String]()
        
        for i in 0..<arrayRates.count {
            dates.append(arrayRates[i].time)

            let dataEntry = ChartDataEntry(x: Double(i), y: arrayRates[i].value)
            dataEntries.append(dataEntry)
        }

        let line = LineChartDataSet(values: dataEntries, label: String(format: "%@-%@", crypto, fiat))
        
        line.circleRadius = 2
        line.lineWidth = 1
        line.highlightColor = UIColor.blue //cross

        data.addDataSet(line)

        let queue = DispatchQueue.main
        queue.async {
            lineChartView.data = nil
            lineChartView.data = data
            lineChartView.chartDescription?.text = "Here will be time"
        }
    }
}
