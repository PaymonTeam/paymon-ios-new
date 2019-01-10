//
// Created by Vladislav on 06/12/2017.
// Copyright (c) 2017 Semen Gleym. All rights reserved.
//

import Foundation
import BigInt
import web3swift
import Alamofire

struct RestoreResult {
    static let success = "success"
    static let errorPassword = "errorPassword"
    static let invalidAccount = "invalidAccount"
    static let someError = "someError"
    static let errorEncode = "errorEncode"
}

class EthereumManager {
    
    static let shared = EthereumManager()
    
    let queue = OperationQueue()
    
    var ks: EthereumKeystoreV3!
    var oldKs:EthereumKeystoreV3!
    var keystoreManager : KeystoreManager!
    
    var balance : BigUInt! = 0
    var cryptoBalance : Double! = 0.0
    var web3 : Web3!
    
    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var keyPath : String!
    var transactions : [EthTransaction] = [] {
        didSet {
            self.updateBalance()
            NotificationCenter.default.post(name: .updateEthTransactions, object: nil)
        }
    }
    
    var sender : Address? {
        didSet {
            DispatchQueue.main.async {
                ExchangeRateParser.shared.parseCourseForWallet(crypto: Money.eth, fiat: User.currencyCode)
//                self.updateTxHistory()
                NotificationCenter.default.post(name: .ethWalletWasCreated, object: nil)
            }
        }
    }
    
    var fiatBalance : Double! = 0.0 {
        didSet {
            DispatchQueue.main.async {
                CryptoManager.shared.ethInfoIsLoaded = true;
                NotificationCenter.default.post(name: .updateBalance, object: nil)
            }
        }
    }
    
    var course : Double! {
        didSet {
            self.updateBalance()
        }
    }
    
    func initWeb() {
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            self.keyPath = self.userDir + "/keystore_\(User.currentUser.id!)"+"/key_eth.json"
            self.keystoreManager = KeystoreManager.managerForPath(self.userDir + "/keystore_\(User.currentUser.id!)")
            
            Web3.default = Web3(infura: .rinkeby)
            self.web3 = Web3.default
            self.web3.addKeystoreManager(self.keystoreManager!)
        }
    }
    
    func initWallet() {
        initWeb()
        if sender == nil {
            queue.addOperation {
                if (self.keystoreManager?.addresses.count == 0) {
                    print("sender return")
                    return
                } else {
                    self.ks = self.keystoreManager?.walletForAddress((self.keystoreManager?.addresses[0])!) as? EthereumKeystoreV3
                }
                guard let sender = self.ks?.addresses.first else {return}
                self.sender = sender
                print("sender \(sender)")
            }
        }
    }
    
    func setSender() {
        guard let sender = self.ks?.addresses.first else {return}
        User.currentUser.ethAddress = sender.address
        self.sender = sender
        print("sender \(sender)")
        UserManager.shared.updateProfileInfo() {_ in}
    }
    
    func createWallet(password : String) {
        initWeb()
        queue.addOperation {
            if (self.keystoreManager?.addresses.count == 0) {
                self.ks = try! EthereumKeystoreV3(password: password)
                let keydata = try! JSONEncoder().encode(self.ks!.keystoreParams)
                FileManager.default.createFile(atPath: self.keyPath, contents: keydata, attributes: nil)
            } else {
                print("return")
                return
            }
            
            self.setSender()
        }
    }
    
    func backupWallet(completionHandler: @escaping (URL) -> ()) {
        if let url = URL(fileURLWithPath: self.userDir + "/keystore_\(User.currentUser.id!)"+"/key_eth.json") as URL? {
            completionHandler(url)
        }
        
    }
    
    func deleteWallet(completionHandler: @escaping (Bool) -> ()) {
        queue.addOperation {
            do {
                try FileManager.default.removeItem(atPath: self.keyPath)
                self.sender = nil
                User.currentUser.ethAddress = ""
                UserManager.shared.updateProfileInfo() {_ in}
                completionHandler(true)
            } catch {
                completionHandler(false)
            }
        }
    }
    
    func restoreWallet(jsonData: Data, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        initWeb()
        
        queue.addOperation {
            
            self.oldKs = self.ks
            self.ks = nil
            self.ks = EthereumKeystoreV3(jsonData)
            if self.ks != nil {
                do {
                    if let privateKey = try self.ks.UNSAFE_getPrivateKeyData(password: password, account: self.ks.addresses.first!) as Data? {
                        self.ks = try EthereumKeystoreV3(privateKey: privateKey)
                        
                        let keydata = try JSONEncoder().encode(self.ks!.keystoreParams)
                        FileManager.default.createFile(atPath: self.keyPath, contents: keydata, attributes: nil)
                        self.setSender()

                        completionHandler((true, RestoreResult.success))
                    }
                } catch AbstractKeystoreError.invalidPasswordError {
                    print("Error restore wallet: invalidPasswordError")
                    completionHandler((false, RestoreResult.errorPassword))

                } catch AbstractKeystoreError.invalidAccountError {
                    print("Error restore wallet: invalidAccountError")
                    completionHandler((false, RestoreResult.invalidAccount))

                } catch EncodingError.invalidValue {
                    completionHandler((false, RestoreResult.errorEncode))

                    print("Error restore wallet(encode): EncodingError.invalidValue")
                } catch let error {
                    completionHandler((false, RestoreResult.someError))

                    print("Some error: ", error)

                }
            } else {
                self.ks = self.oldKs
                print("error encode")
                completionHandler((false, RestoreResult.someError))

            }
            
        }
    }
    
    func updateTxHistory() {
        
        let urlString = "https://api-rinkeby.etherscan.io/api?module=account&action=txlist&address=\(sender!.address)&startblock=0&endblock=99999999&sort=desc&apikey=YourApiKeyToken"
        Alamofire.request(urlString, method: .get).response(completionHandler: { response in
            if response.error == nil && response.data != nil {
                do {
//                    guard let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {return}
//                    print(json)
                    let ethResult : EthResult = try JSONDecoder().decode(EthResult.self, from: response.data!)
                    self.transactions = ethResult.result
                } catch let error {
                    print("TxUpdate: Error decode json", error)
                }
            } else {
                print("Error parse http", response.error!)
            }
        })
    }
    
    func updateBalance() {
        queue.addOperation {
            if self.sender != nil {
                let balance = try! self.web3.eth.getBalance(address: self.sender!)
                self.balance = balance
                self.cryptoBalance = Double(balance) / Money.fromWei
                self.fiatBalance = self.cryptoBalance * self.course
                //TODO вылетало
            }
        }
    }
    
    func send(gasPrice : BigUInt, gasLimit : Int64, value : Int64, toAddress : String, password : String, completionHandler: @escaping ((Bool,String)) -> ()) {
        queue.addOperation {
            let coldWalletABI = "[{\"payable\":true,\"type\":\"fallback\"}]"
            var options = Web3Options.default
            options.gasPrice = gasPrice
            options.gasLimit = BigUInt(gasLimit)
            options.value = BigUInt(value)
            options.from = self.sender
            options.to = Address(toAddress)
            let estimatedGas = try! self.web3.contract(coldWalletABI, at: self.sender).method(options: options).estimateGas(options: nil)
            options.gasLimit = estimatedGas
            let intermediateSend = try! self.web3.contract(coldWalletABI, at: self.sender).method(options: options)
            let sendingResult = try! intermediateSend.send(password: password)
            let txid = sendingResult.hash
            //TODO: Notif tx was sent
            print("On Rinkeby TXid = " + txid)
            completionHandler((true, txid))
        }
    }
}
