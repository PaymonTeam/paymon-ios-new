//
//  BtcApi.swift
//  paymon
//
//  Created by Maxim Skorynin on 31/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import BitcoinKit

class BtcApi {
    
    private let apiEndPoint = "https://test-insight.bitpay.com/api" // Mainnet: "https://insight.bitpay.com/api"
    
    func getUnspentOutputs(withAddresses addresses: [String], completionHandler: @escaping ([UnspentOutput]) -> ()) {
        let paramAddrs = addresses.joined(separator: ",")
        let url = "\(apiEndPoint)/addrs/\(paramAddrs)/utxo"
        print("get unspent outputs url = \(url)")
        get(url: url, completion: { (data) in
            do {
                let utxos = try JSONDecoder().decode([UnspentOutput].self, from: data)
                completionHandler(utxos)
            } catch {
                print("Serialize Error")
            }
        })
    }
    
    func getTransaction(withAddresses address: String, completionHandler: @escaping ([CodableTx]) -> ()) {
        let url = "\(apiEndPoint)/txs"
        print("Transactions by Address: url = \(url)")
        get(url: url, completion: { (data) in
            do {
                let transactions = try JSONDecoder().decode(Transactions.self, from: data)
                completionHandler(transactions.transactions)
            } catch {
                print("Serialize Error")
            }
        }, queryItems: [URLQueryItem(name: "address", value: address)])
    }
    
    func postTx(withRawTx rawTx: String, completionHandler: @escaping (_ txId: String?, _ error: String?) -> ()) {
        let url = "\(apiEndPoint)/tx/send"
        print("url = \(url)")
        print("rawTx = \(rawTx)")
        post(url: url, parameters: ["rawtx": rawTx], completion:  { (data) in
            guard let data = data else {
                completionHandler(nil, "response data is nil")
                return
            }
            do {
                let tx = try JSONDecoder().decode(CodableTx.self, from: data)
                print(tx.txid)
                completionHandler(tx.txid, nil)
            } catch {
                print("Serialize Error")
                if let error = String(data: data, encoding: .utf8) {
                    completionHandler(nil, error)
                } else {
                    completionHandler(nil, "unknown error")
                }
            }
        })
    }
    
    func get(url urlString: String, completion: @escaping (Data) -> (), queryItems: [URLQueryItem]? = nil) {
        var compnents = URLComponents(string: urlString)
        compnents?.queryItems = queryItems
        guard let url = compnents?.url else {
            print("cannot create url")
            return
        }
        print("url \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    print("error: \(error)")
                } else {
                    print("Unknown Error")
                }
                return
            }
            completion(data)
        }
        
        task.resume()
    }
    
    func post(url urlString: String, parameters: [String: Any], completion: @escaping (Data?) -> ()) {
        guard let url = URL(string: urlString) else {
            print("cannot create url from url string")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("error: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("post error: \(error)")
            }
            completion(data)
        }
        task.resume()
    }
    
    func getBalance(publicKey : String, isTestNet: Bool, completionHandler: @escaping (Int64) -> ()) {
        let network = !isTestNet ? "main" : "test3"
        
        let urlString = "https://api.blockcypher.com/v1/btc/\(network)/addrs/\(publicKey)/balance"
        guard let url = URL(string: urlString) else {
            return
        }
        print(url)
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
                if let balance = json["final_balance"] as? Int64 {
                    completionHandler(balance)
                }
                
            } catch let jsonError{
                print("Error srializing json:", jsonError)
            }
            
            }.resume()
    }
    
}
