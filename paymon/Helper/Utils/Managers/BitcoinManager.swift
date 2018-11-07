//
//  BitcoinManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 29/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import BitcoinKit
import UIKit
import MBProgressHUD

class BitcoinManager {

    static let shared = BitcoinManager()
    
    private(set) var wallet : Wallet?
    var transactions = [CodableTx]()
    private(set) var balance : Decimal! = 0.00
    private(set) var balanceSatoshi : Decimal! = 0.00

    private(set) var fiatBalance : Decimal! = 0.00 {
        didSet {
            NotificationCenter.default.post(name: .updateBtcBalance, object: nil)
        }
    }
    var publicKey : String!
    var course: Decimal! = 1.0
    
    private init() {
    }
    
    func createBtcWallet(password: String) {
        if wallet == nil {
            let privateKey = PrivateKey(network: .testnetBTC)
            let wif = privateKey.toWIF()
            wallet = try! Wallet(wif: wif)
            if wallet != nil {
                BitcoinManager.shared.savePrivateKey()
                setPublicKey()
                NotificationCenter.default.post(name: .walletWasCreated, object: nil)
            }
        }
    }
    
    func restoreFromMemory(privateKey: String) {
        
        if let restoreWallet = try! Wallet(wif: privateKey) as Wallet? {
            self.wallet = restoreWallet
            setPublicKey()
            print("Wallet was restore from memory: PrivateKey: \(wallet!.privateKey.toWIF())")
            print("Wallet was restore from memory: PublicKey: \(wallet!.publicKey.toCashaddr().base58)")
            NotificationCenter.default.post(name: .walletWasCreated, object: nil)
            updateTxHistory()
        }
    }
    
    func setPublicKey() {
        publicKey = wallet!.publicKey.toCashaddr().base58
    }
    
    func restore(privateKey: String, vc : UIViewController) {
        if privateKey.count > 5 {
            do {
                let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)

                if let restoreWallet = try Wallet(wif: privateKey) as Wallet? {
                    self.wallet = restoreWallet
                    print("Wallet was restore: PrivateKey: \(self.wallet!.privateKey.toWIF())")
                    print("Wallet was restore: PublicKey: \(self.wallet!.publicKey.toCashaddr().base58)")
                    self.updateTxHistory()
                    if self.wallet != nil {
                        BitcoinManager.shared.savePrivateKey()
                        self.setPublicKey()
                        NotificationCenter.default.post(name: .walletWasCreated, object: nil)
                    }
                }
            } catch PrivateKeyError.invalidFormat {
                print("Invalid format private key")
                _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "You entered an incorrect private key".localized, vc: vc)
            } catch {
                print("Some error")
            }
        } else {
            _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "You entered an incorrect private key".localized, vc: vc)
        }
    }
    
    func restoreByPrivateKey(vc: UIViewController) {
        
        let alert = UIAlertController(title: "Restore wallet".localized, message: "Enter private key".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { (nil) in
            let textField = alert.textFields![0] as UITextField
            if let privateKey = textField.text {
                print(privateKey)
                self.restore(privateKey: privateKey, vc: vc)
            }
        }))
        alert.addTextField { (textField) in
            textField.placeholder = "Enter private key".localized
        }
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteWallet(vc: UIViewController) {
        if wallet != nil && User.currentUser != nil {
            let alertRemove = UIAlertController(title: "Remove wallet".localized, message: "Before removing your wallet, make sure you back up your wallet".localized, preferredStyle: UIAlertController.Style.alert)
            
            alertRemove.addAction(UIAlertAction(title: "Backup".localized, style: UIAlertAction.Style.default, handler: { (action) in
                self.backup(vc: vc)
            }))
            
            alertRemove.addAction(UIAlertAction(title: "Remove".localized, style: UIAlertAction.Style.default, handler: { (action) in
                KeychainWrapper.standard.removeObject(forKey: UserDefaultKey.BITCOIN_PRIVATE_KEY + String(User.currentUser.id))
                self.publicKey = ""
                self.wallet = nil
                DispatchQueue.main.async {
                    vc.dismiss(animated: true, completion: nil)
                }
            }))
            
            DispatchQueue.main.async {
                vc.present(alertRemove, animated: true) {
                    () -> Void in
                }
            }
        }
    }
    
    func updateTxHistory() {
        BtcApi().getTransaction(withAddresses: wallet!.publicKey.toLegacy().base58, completionHandler: { [weak self] (transactrions:[CodableTx]) in
            self?.transactions = transactrions
            print("Список транзакций \(String(describing: self?.transactions))")
            self?.updateBalance()
            NotificationCenter.default.post(name: .updateBtcTransactions, object: nil)
        })
    }
    
    func updateBalance() {
        BtcApi().getBalance(publicKey: wallet!.publicKey.toLegacy().base58, isTestNet: true, completionHandler: {[weak self] (balance:Int64) in
            CryptoManager.shared.btcInfoIsLoaded = true
            print("Balance \(balance)")
            self!.balance = Decimal(balance) / 100000000
            self!.balanceSatoshi = Decimal(balance)
            self!.fiatBalance = self!.balance * self!.course
            print("Balance \(String(describing: self!.balance))")

        })
    }
    
    func getTxHistory() -> [CodableTx] {
        return self.transactions
    }
    
    func getBalance() -> Decimal {
        return self.balance
    }
    
    func getFiatBalance() -> Decimal {
        return self.fiatBalance
    }
    
    func savePrivateKey() {
        if User.currentUser == nil {
            print("User is nil")
            return
        }
        print("SavePrivateKey \(String(describing: self.wallet?.privateKey.toWIF()))")
        if let privateKeyString = self.wallet?.privateKey.toWIF() {
            KeychainWrapper.standard.set(privateKeyString, forKey: UserDefaultKey.BITCOIN_PRIVATE_KEY + String(User.currentUser.id), withAccessibility: KeychainItemAccessibility.always)
        }
    }
    
    func loadPrivateKey() -> String? {
        if User.currentUser == nil {
            print("User is nil")
            return nil
        }
        if let privateKey = KeychainWrapper.standard.string(forKey: UserDefaultKey.BITCOIN_PRIVATE_KEY + String(User.currentUser.id)) {
            print("LoadPrivateKey \(privateKey)")

            return privateKey
        } else {
            return nil
        }
    }
    
    /*Send transaction*/
    
    func sendToAddress(amount: Int64, fee: Int64, toAddress: String) {
        print("start transaction amount: \(amount)")
        let toAddress: Address = try! AddressFactory.create(toAddress)
        print("toAddress \(toAddress.base58)")
        let changeAddress: Address = self.wallet!.publicKey.toCashaddr()
        let legacyAddress: String = self.wallet!.publicKey.toLegacy().description
        
        BtcApi().getUnspentOutputs(withAddresses: [legacyAddress], completionHandler: { [weak self] (unspentOutputs: [UnspentOutput]) in
            guard let strongSelf = self else {
                return
            }
            let utxos = unspentOutputs.map { $0.asUnspentTransaction() }
            let unsignedTx = strongSelf.createUnsignedTx(toAddress: toAddress, amount: amount, fee: fee, changeAddress: changeAddress, utxos: utxos)
            let signedTx = strongSelf.signTx(unsignedTx: unsignedTx, keys: [self!.wallet!.privateKey])
            let rawTx = signedTx.serialized().hex
            
            BtcApi().postTx(withRawTx: rawTx, completionHandler: { (txid, error) in
                if txid != nil {
                    print("success: \(String(describing: txid))")
                } else {
                    print("Error send", error ?? "error nil")
                }
            })
        })
    }
    
    public func selectTx(from utxos: [UnspentTransaction], amount: Int64) -> [UnspentTransaction] {
        return utxos
    }
    
    public func createUnsignedTx(toAddress: Address, amount: Int64, fee: Int64, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
        let utxos = selectTx(from: utxos, amount: amount)
        let totalAmount: Int64 = Int64(truncating: NSDecimalNumber(decimal: BitcoinManager.shared.balanceSatoshi))
        print("create transaction total amount: \(totalAmount)")

        print("Fee \(fee)")
        let change: Int64 = totalAmount - amount - fee
        print("change: \(change)")
        
        let lockScriptTo = Script(address: toAddress)
        let lockScriptChange = Script(address: changeAddress)
        
        let toOutput = TransactionOutput(value: amount, lockingScript: lockScriptTo!.data)
        let changeOutput = TransactionOutput(value: change, lockingScript: lockScriptChange!.data)
        
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }
        
        // Signing
        let hashType = SighashType.BTC.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
            
            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                continue
            }
            
            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BTC.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: key)
            let txin = inputsToSign[i]
            let pubkey = key.publicKey()
            
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            
            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
        }
        return transactionToSign
    }
    
    func backup(vc: UIViewController) {
        let privateKey = self.wallet?.privateKey.toWIF()
        let currentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_yyyy"
        let path = URL(fileURLWithPath: currentPath.path + "/" + "btc_private_key_\(dateFormatter.string(from: Date()))")
        let rawData: Data? = privateKey!.data(using: .utf8)
        if FileManager.default.createFile(atPath: path.path, contents: rawData, attributes: nil) == true {
            let shareActivity = UIActivityViewController(activityItems: [path], applicationActivities: [])
            
            shareActivity.popoverPresentationController?.sourceView = vc.view
            shareActivity.popoverPresentationController?.sourceRect = vc.view.bounds
            vc.present(shareActivity, animated: true)
        } else {
            print("File not created")
        }
    }
    
    func checkPasswordWallet(vc: UIViewController, completionHandler: @escaping (Bool) -> ()) {
        let alertCheckPassword = UIAlertController(title: "Security password".localized, message: "Enter the password that was specified when creating or restoring the wallet".localized, preferredStyle: UIAlertController.Style.alert)
        
        alertCheckPassword.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
        alertCheckPassword.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { (nil) in
            let textField = alertCheckPassword.textFields![0] as UITextField
            if User.passwordWallet == textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                completionHandler(true)
            } else {
                completionHandler(false)
                
            }
        }))
        alertCheckPassword.addTextField { (textField) in
            textField.placeholder = "Enter security password".localized
        }
        
        DispatchQueue.main.async {
            vc.present(alertCheckPassword, animated: true) {
                () -> Void in
            }
        }
    }
}
