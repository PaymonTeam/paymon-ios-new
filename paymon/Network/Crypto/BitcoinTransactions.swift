//
//  BitcoinTransactions.swift
//  paymon
//
//  Created by Maxim Skorynin on 25.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

struct BitcoinTransaction {
    var type : TransactionType
    var from : String
    var amount : String
    var time : String
    var avatar : UIImage
}

class BitcoinTransactions {
    
    public class func getTransactions(){
        var result : [BitcoinTransaction] = []
        
//        for tx in BitcoinManager.shared.transactions {
//            
////            let to = tx.to
//            let from = tx.from.base58
//            let value = Double(tx.amount) / 100000000.0
//            let transactionType : TransactionType = tx.state == .sent ? .sent : .received
//            
//            
//           result.append(BitcoinTransaction(type: transactionType, from: tx.from.base58, amount: String(value), time: "", avatar: UIImage()))
//        }
        NotificationCenter.default.post(Notification(name: .updateTransaction, object: result))
    }
    
}
