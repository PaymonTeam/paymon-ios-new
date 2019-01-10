//
//  EthTransaction.swift
//  paymon
//
//  Created by Maxim Skorynin on 26/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import BlockiesSwift

public class EthTransaction : Codable {
    var blockNumber : String
    var timeStamp : String
    var hash : String
    var nonce : String
    var from : String
    var to : String
    var value : String
    var gas : String
    var gasPrice : String
    var isError : String
    var gasUsed : String
    var confirmations : String
}

public class EthResult : Codable {
    let result: [EthTransaction]
}

class EthTransactions {
    
    public class func getTransactions(completionHandler: @escaping ([Transaction]) -> ()){
        var result : [Transaction] = []
        
        for tx in EthereumManager.shared.transactions {
            
            let blockies = Blockies(seed: tx.from)
            var image = UIImage()
            if let bimage = blockies.createImage() {
                image = bimage
            }
            
            let transactionType : TransactionType = tx.from.lowercased() == EthereumManager.shared.sender!.address.lowercased() ? .sent : .received
            let value = Decimal(tx.value) / Decimal(Money.fromWei)
            
            result.append(Transaction(type: transactionType, from: tx.from, amount: String(value.double), time: Utils.formatDateTime(timestamp: Int32(tx.timeStamp)!), avatar: image, txInfo : tx))
        }
        
        completionHandler(result)
    }
    
}
