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
        //get Bitcoin transactions
        
        var result : [BitcoinTransaction] = []
        
        //For Example
        result.append(BitcoinTransaction(type: .received, from: "Maks Skorynin", amount: "+939.03", time: "12:07", avatar: UIImage()))
        result.append(BitcoinTransaction(type: .received, from: "Maks Skorynin", amount: "+939.03", time: "12:07", avatar: UIImage()))
        result.append(BitcoinTransaction(type: .sent, from: "Anatoliy Marko", amount: "-51234.2", time: "Yestarday", avatar: UIImage()))
        result.append(BitcoinTransaction(type: .sent, from: "Anatoliy Marko", amount: "-51234.2", time: "Yestarday", avatar: UIImage()))
        
        NotificationCenter.default.post(Notification(name: .updateTransaction, object: result))

        
    }
    
}
