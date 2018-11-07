//
//  ExchangeRatesParser.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 10.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

struct ExchangeRate {
    let crypto : String
    let fiat : String
    let value : Double
}

class ExchangeRateParser{
    
    static let shared = ExchangeRateParser()
    
    func parseCourse(crypto: String, fiat: String) {
        var result : Double!
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(crypto)&tsyms=\(fiat)"
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                if let rates = json[crypto] as? [String: Any] {
                    result = rates[fiat] as? Double
                }
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
            
            NotificationCenter.default.post(Notification(name: .getCourse, object: result))
        }.resume()
    }
    
    func parseCourseForWallet(crypto: String, fiat: String) {
        var result : Double!
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(crypto)&tsyms=\(fiat)"
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                if let rates = json[crypto] as? [String: Any] {
                    result = rates[fiat] as? Double
                }
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
            
            BitcoinManager.shared.course = Decimal(String(format: "%.2f", result))
            if BitcoinManager.shared.wallet != nil {
                BitcoinManager.shared.updateTxHistory()
            }
            
            }.resume()
    }
    
    func parseAllExchangeRates(){
        var result : [ExchangeRate] = [ExchangeRate]()
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH&tsyms=USD,EUR,RUB"
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                if let rates = json["BTC"] as? [String: Any] {
                    for rate in rates {
                        result.append(ExchangeRate(crypto: "BTC", fiat: rate.key, value: rate.value as? Double ?? Double(rate.value as! Int)))
                    }
                }
                
                if let rates = json["ETH"] as? [String: Any] {
                    for rate in rates {
                        result.append(ExchangeRate(crypto: "ETH", fiat: rate.key, value: rate.value as? Double ?? Double(rate.value as! Int)))
                    }
                }
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
            
            NotificationCenter.default.post(Notification(name: .updateRates, object: result))
            
        }.resume()
    }

}
