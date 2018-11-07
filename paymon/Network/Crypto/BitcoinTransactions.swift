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
        
        for tx in BitcoinManager.shared.getTxHistory() {
            
            let inputAddress = tx.inputs[0].address
            let from = tx.outputs[0].scriptPubKey.addresses[0]
            let value = inputAddress ==  BitcoinManager.shared.publicKey ? tx.outputs[0].value : tx.outputs[1].value
            let transactionType : TransactionType = tx.inputs[0].address != BitcoinManager.shared.publicKey ? .received : .sent
            
           result.append(BitcoinTransaction(type: transactionType, from: from, amount: value.description, time: Utils.formatDateTime(timestamp: Int32(tx.time), chatHeader: false, abbreviation: TimeZone.current.abbreviation()), avatar: UIImage()))
        }
        NotificationCenter.default.post(Notification(name: .updateTransaction, object: result))
    }
    
}
