//
//  UnspentOutput.swift
//  paymon
//
//  Created by Maxim Skorynin on 31/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import BitcoinKit

struct UnspentOutput: Codable {
    
    let address: String
    let confirmations: Int
    let satoshis: Int64
    let scriptPubKey: String
    let txID: String
    let vout: UInt32
    let amount: Decimal
    
    enum CodingKeys: String, CodingKey {
        case address
        case confirmations
        case satoshis
        case scriptPubKey
        case txID = "txid"
        case vout
        case amount
    }
}

extension UnspentOutput {
    func asUnspentTransaction() -> UnspentTransaction {
        let transactionOutput = TransactionOutput(value: satoshis, lockingScript: Data(hex: scriptPubKey)!)
        let txid: Data = Data(hex: String(txID))!
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: vout)
        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
    }
}
