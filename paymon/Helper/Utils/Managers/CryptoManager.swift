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
    var btcInfoIsLoaded = false
    var ethInfoIsLoaded = false
    
    func getPaymonWalletInfo() -> CellMoneyData {
        
        let paymonData = CellCreatedMoneyData()
        let userHavePaymonWallet = false
        if (userHavePaymonWallet) {

            /*Block for test. Here we get Paymon wallet info*/
            paymonData.currancyAmount = 12.572
            paymonData.fiatAmount = 6723.13
            paymonData.cryptoHint = Money.pmnc
            paymonData.icon = Money.pmncIcon
            paymonData.fiatHint = User.currencyCode
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
        
        let ethereumData = CellCreatedMoneyData()
        
        if EthereumManager.shared.sender != nil {
            ethereumData.currancyAmount = EthereumManager.shared.cryptoBalance
            ethereumData.fiatAmount = EthereumManager.shared.fiatBalance
            ethereumData.cryptoHint = Money.eth
            ethereumData.icon = Money.ethIcon
            ethereumData.fiatHint = User.currencyCode
            ethereumData.fiatColor = UIColor.AppColor.Green.rub
            ethereumData.cryptoColor = UIColor.AppColor.Gray.ethereum
            ethereumData.cryptoType = .ethereum
            return ethereumData
        } else {
            return self.getNotCreatedData(cryptoType: .ethereum)
        }
        
    }
    
    func getBitcoinWalletInfo() -> CellMoneyData {
        let bitcoinData = CellCreatedMoneyData()
        
            if BitcoinManager.shared.wallet == nil {
//                let keychain = Keychain()
//                if let seed = keychain.get(for: "seed_\(String(describing: User.currentUser.id))") {
//                    BitcoinManager.shared.importWallet(seed: seed)
//                } else {
//                    return self.getNotCreatedData(cryptoType: .bitcoin)
//                }
                return self.getNotCreatedData(cryptoType: .bitcoin)

            }
        
            if User.currentUser != nil {
//                bitcoinData.currancyAmount = BitcoinManager.shared.balance
//                bitcoinData.fiatAmount = BitcoinManager.shared.fiatBalance
                bitcoinData.cryptoHint = Money.btc
                bitcoinData.icon = Money.btcIcon
                bitcoinData.fiatHint = User.currencyCode
                bitcoinData.fiatColor = UIColor.AppColor.Green.rub
                bitcoinData.cryptoColor = UIColor.AppColor.Orange.bitcoin
                bitcoinData.cryptoType = .bitcoin
                return bitcoinData
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
    
    func checkEthereumWallet(wallet : String) -> Bool {
        return wallet.matches(Money.ETHEREUM_WALLET_QR_REGEX)
    }
    
    
    func cutWallet(scan : String, currency : String) -> String{
        
        var cutString = ""
        let parts = scan.components(separatedBy: ":")
        
        if currency == Money.btc {
            if checkBitcoinWallet(wallet: scan) {
                if parts.count == 2 {
                    cutString = parts[1].replacingOccurrences(of: "-", with: "")
                } else {
                    cutString = scan
                }
            }
        } else if currency == Money.eth {
            if checkEthereumWallet(wallet: scan) {
                if parts.count == 2 {
                    cutString = parts[1].replacingOccurrences(of: "-", with: "")
                } else {
                    cutString = scan
                }
            }
        }
        return cutString

    }
    
}
