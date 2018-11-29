//
//  ExchangeRatesParser.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 10.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct ExchangeRate {
    let crypto : String
    let fiat : String
    let value : Double
}

class ExchangeRateParser{
    
    static let shared = ExchangeRateParser()
    
    func parseCourse(crypto: String, fiat: String, completionHandler: @escaping (Double) -> ()) {
        var result : Double!
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(crypto)&tsyms=\(fiat)"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil{
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                if let rates = json[crypto] as? [String: Any] {
                    result = rates[fiat] as? Double
                }
                completionHandler(result)
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
            
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func parseCourseForWallet(crypto: String, fiat: String) {
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(crypto)&tsyms=\(fiat)"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                    if let rates = json[crypto] as? [String: Any] {
                        if let result = rates[fiat] as? Double {
                            switch crypto {
                            case Money.eth: EthereumManager.shared.course = result
                            case Money.btc: BitcoinManager.shared.course = result
                            default: break
                            }
                        }
                    }
                    
                } catch let jsonError{
                    print("Error srializing json:", jsonError)
                }
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func parseAllExchangeRates(completionHandler: @escaping ([ExchangeRate]) -> ()){
        var result : [ExchangeRate] = [ExchangeRate]()
        
        let urlString = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH&tsyms=USD,EUR,RUB"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
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
                    completionHandler(result)
                    
                } catch let jsonError{
                    print("Error srializing json:", jsonError)
                }
                
            } else {
                print("Error parse http", response.error!)
            }
        })
            
    }
}
