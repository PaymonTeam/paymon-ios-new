//
//  ExchangeRateForChartsParser.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 11.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import ScrollableGraphView

public class Rate {
    var values : [Double] = []
    var dates : [String] = []
}

class ExchangeRatesForChartsParser {
    
    static let shared = ExchangeRatesForChartsParser()
    
    func parse(urlString : String, interval : String) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let result = Rate()
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                
                if let rates = json["Data"] as? [[String: Any]] {
                    for rate in rates {
                        let timeChart = Utils.formatDateTimeCharts(timestamp: Int64(rate["time"] as! Int), interval: interval)
//                        print(timeChart)
                        result.values.append(rate["close"] as? Double ?? Double(rate["close"] as! Int))
                        result.dates.append(timeChart)

                    }
                }
                
                NotificationCenter.default.post(name: .updateCharts, object: result)

                
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
        }.resume()
    }
}
