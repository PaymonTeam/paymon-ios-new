//
//  CryptoManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 03.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class CryptoManager {
    
    static func getPaymonWalletInfo() -> CellMoneyData {
        
        let paymonData = CellCreatedMoneyData()
        let userHavePaymonWallet = true
        if (userHavePaymonWallet) {

            /*Block for test. Here we get Paymon wallet info*/
            paymonData.currancyAmount = 12.572
            paymonData.fiatAmount = 6723.13
            paymonData.cryptoHint = Money.pmnc
            paymonData.icon = Money.pmncIcon
            paymonData.fiatHint = Money.rub
            paymonData.fiatColor = UIColor.AppColor.Green.rub
            paymonData.cryptoColor = UIColor.AppColor.Blue.paymon
            paymonData.cryptoType = .paymon
            /*******************/
            return paymonData
        } else {
            return getNotCreatedData(cryptoType: .paymon)

        }
    }
    
    static func getEthereumWalletInfo() -> CellMoneyData {
        
        let ethereumData : CellCreatedMoneyData
        let userHaveEtherWallet = false
        
        if (userHaveEtherWallet) {
        
            ethereumData = CellCreatedMoneyData()
            /*Block for test. Here we get ethereum wallet info*/
            ethereumData.currancyAmount = 4.523
            ethereumData.fiatAmount = 23552.98
            ethereumData.cryptoHint = Money.eth
            ethereumData.icon = Money.ethIcon
            ethereumData.fiatHint = Money.rub
            ethereumData.fiatColor = UIColor.AppColor.Green.rub
            ethereumData.cryptoColor = UIColor.AppColor.Gray.ethereum
            ethereumData.cryptoType = .ethereum
            return ethereumData
            /*******************/

        } else {
            return getNotCreatedData(cryptoType: .ethereum)
        }
        
    }
    
    static func getBitcoinWalletInfo() -> CellMoneyData {
        let bitcoinData = CellCreatedMoneyData()
        let userHaveBitcoinWallet = true

        if (userHaveBitcoinWallet) {

            /*Block for test. Here we get bitcoin wallet info*/
            bitcoinData.currancyAmount = 1.023
            bitcoinData.fiatAmount = 87403.04
            bitcoinData.cryptoHint = Money.btc
            bitcoinData.icon = Money.btcIcon
            bitcoinData.fiatHint = Money.rub
            bitcoinData.fiatColor = UIColor.AppColor.Green.rub
            bitcoinData.cryptoColor = UIColor.AppColor.Orange.bitcoin
            bitcoinData.cryptoType = .bitcoin
            return bitcoinData
            /*******************/

        } else {
            return getNotCreatedData(cryptoType: .bitcoin)
        }
        
    }
    
    static func getNotCreatedData(cryptoType : CryptoType) -> CellMoneyData {
        let notCreated = CellMoneyData()
        
        switch cryptoType {
        case .bitcoin:
            notCreated.cryptoColor = UIColor.AppColor.Orange.bitcoin
            notCreated.icon = Money.btcIcon
        case .ethereum:
            notCreated.cryptoColor = UIColor.AppColor.Gray.ethereum
            notCreated.icon = Money.ethIcon
        case .paymon:
            notCreated.cryptoColor = UIColor.AppColor.Blue.paymon
            notCreated.icon = Money.pmncIcon
        }
    
        notCreated.cryptoType = cryptoType
        
        return notCreated
    }
    
    
    
}
