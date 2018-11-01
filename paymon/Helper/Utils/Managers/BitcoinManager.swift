//
//  BitcoinManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 29/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import BitcoinKit

class BitcoinManager {
    static let shared = BitcoinManager()
    
    private(set) var hDwallet : HDWallet? {
        didSet {
            NotificationCenter.default.post(name: .walletChanged, object: self)
        }
    }
    
    private(set) var wallet : Wallet?
    var transactions = [CodableTx]()
    var balance : Decimal!
    
    private init() {
    }
    
    func createBtcWallet(password: String) {
        if wallet == nil {
            let privateKey = PrivateKey(network: .testnetBTC)
            let wif = privateKey.toWIF()
            wallet = try! Wallet(wif: wif)
            if wallet != nil {
                //TODO: закоментить после тестов
                User.haveBitcoinWallet = true
                NotificationCenter.default.post(name: .walletWasCreated, object: nil)
            }
        } else {
            let privateKey = PrivateKey(network: .testnetBTC)
            let wif = privateKey.toWIF()
            wallet = try! Wallet(wif: wif)
            if wallet != nil {
                //TODO: закоментить после тестов
                User.haveBitcoinWallet = true
                NotificationCenter.default.post(name: .walletWasCreated, object: nil)
            }
            //TODO: Предложить сделать бэкап прежде чем создать новый кошелек
        }
    }

    func restoreFromPrivateKey(privateKey: String) {
        print("Private key format \(privateKey)")
        
        if let restoreWallet = try! Wallet(wif: privateKey) as Wallet? {
            self.wallet = restoreWallet
            print("Wallet was restore: PrivateKey: \(wallet!.privateKey.toWIF())")
            print("Wallet was restore: PublicKey: \(wallet!.publicKey.toCashaddr().base58)")
            print("Wallet was restore: Network \(wallet!.publicKey.toLegacy().network.scheme)")
            updateTxHistory()
        }
    }
    
    func updateTxHistory() {
        BtcApi().getTransaction(withAddresses: wallet!.publicKey.toLegacy().description, completionHandler: { [weak self] (transactrions:[CodableTx]) in
            self?.transactions = transactrions
            print("Список транзакций \(String(describing: self?.transactions))")
            self?.updateBalance()
        })
    }
    
    func updateBalance() {
        let cashaddr = wallet!.publicKey.toCashaddr().cashaddr
        let address = cashaddr.components(separatedBy: ":")[1]
        let addition = transactions.filter { $0.direction(addresses: [address]) == .received }.reduce(0) { $0 + $1.amount(addresses: [address]) }
        let subtraction = transactions.filter { $0.direction(addresses: [address]) == .sent }.reduce(0) { $0 + $1.amount(addresses: [address]) }
        let newBalance = addition - subtraction
        balance = newBalance
        print("Balance \(newBalance)")
    }
    
    func getTxHistory() -> [CodableTx] {
        updateTxHistory()
        return self.transactions
    }
    
    func getBalance() -> Decimal {
        updateBalance()
        return self.balance
    }
    
    func savePrivateKey() {
        if User.currentUser == nil {
            print("User is nil")
            return
        }
        let stream = SerializedStream()
       
        print("SavePrivateKey \(self.wallet?.privateKey.toWIF())")
        stream?.write(self.wallet?.privateKey.toWIF())
        let privateKeyString = stream!.out.base64EncodedString()
        KeychainWrapper.standard.set(privateKeyString, forKey: UserDefaultKey.BITCOIN_PRIVATE_KEY + String(User.currentUser.id), withAccessibility: KeychainItemAccessibility.always)
    }
    
    func loadPrivateKey() -> String? {
        if User.currentUser == nil {
            print("User is nil")
            return nil
        }
        if let privateKey = KeychainWrapper.standard.string(forKey: UserDefaultKey.BITCOIN_PRIVATE_KEY + String(User.currentUser.id)) {
            let data = Data(base64Encoded: privateKey)
            let result = String(data: data!, encoding: .utf8)
            print("LoadPrivateKey \(result)")

            return result
        } else {
            return nil
        }
    }
}
