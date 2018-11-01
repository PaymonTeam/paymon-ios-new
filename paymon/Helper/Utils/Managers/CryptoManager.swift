//
//  CryptoManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 03.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class CryptoManager {
    
    static let shared = CryptoManager()
    
    func getPaymonWalletInfo() -> CellMoneyData {
        
        let paymonData = CellCreatedMoneyData()
        let userHavePaymonWallet = false
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
    
    func getEthereumWalletInfo() -> CellMoneyData {
        
        let ethereumData : CellCreatedMoneyData
        let userHaveEtherWallet = true
        
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
            return self.getNotCreatedData(cryptoType: .ethereum)
        }
        
    }
    
    func getBitcoinWalletInfo() -> CellMoneyData {
        let bitcoinData = CellCreatedMoneyData()
    
        if BitcoinManager.shared.wallet == nil {
            let privateKey = BitcoinManager.shared.loadPrivateKey()
            if privateKey != nil {
                BitcoinManager.shared.restoreFromPrivateKey(privateKey: privateKey!)
            } else {
                return self.getNotCreatedData(cryptoType: .bitcoin)
            }
        }
        
        if User.currentUser != nil {
            if User.haveBitcoinWallet {
                /*Block for test. Here we get bitcoin wallet info*/
                bitcoinData.currancyAmount = BitcoinManager.shared.getBalance()
                bitcoinData.fiatAmount = (BitcoinManager.shared.getBalance() + 1) * 1000
                bitcoinData.cryptoHint = Money.btc
                bitcoinData.icon = Money.btcIcon
                bitcoinData.fiatHint = Money.rub
                bitcoinData.fiatColor = UIColor.AppColor.Green.rub
                bitcoinData.cryptoColor = UIColor.AppColor.Orange.bitcoin
                bitcoinData.cryptoType = .bitcoin
                return bitcoinData
            } else {
                return self.getNotCreatedData(cryptoType: .bitcoin)
            }
        } else {
            return self.getNotCreatedData(cryptoType: .bitcoin)
        }
    }
    
    func getNotCreatedData(cryptoType : CryptoType) -> CellMoneyData {
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
    
    func checkBitcoinWallet(wallet : String) -> Bool {
        return wallet.matches(Money.BITCOIN_WALLET_QR_REGEX)
    }
    
    func cutBitcoinWallet(scan : String) -> String{
        
        var cutString = ""
        let parts = scan.components(separatedBy: ":")
        
        if checkBitcoinWallet(wallet: scan) {
            if parts.count == 2 {
                cutString = parts[1].replacingOccurrences(of: "-", with: "")
            } else {
                cutString = scan
            }
        }
        
        return cutString
    }
    
}
