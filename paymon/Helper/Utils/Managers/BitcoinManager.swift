//
//  BitcoinManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 29/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import KeychainAccess

public class BitcoinManager {
    
    let keyChain = Keychain()
    static let shared = BitcoinManager()
    
    private(set) var balance : Decimal! = 0.00
    private(set) var balanceSatoshi : Decimal! = 0.00
    
    private(set) var wallet: Data? {
        didSet {

        }
    }

    private(set) var fiatBalance : Decimal! = 0.00 {
        didSet {
            NotificationCenter.default.post(name: .updateBalance, object: nil)
        }
    }
    var publicKey : String!
    var course: Double! = 1.0
    
//    func createBtcWallet(mnemonic : [String]) {
//        let seed = Mnemonic.seed(mnemonic: mnemonic)
//        importWallet(seed: seed)
//    }
//
//    func importWallet(seed: Data) {
//        let keychain = Keychain()
//        keychain.set(seed, for: "seed_\(String(describing: User.currentUser.id))")
//        self.wallet = HDWallet(seed: seed, network: network)
//    }
//
//    func deleteWallet(vc:UIViewController) {
//
//        let alertRemove = UIAlertController(title: "Remove wallet".localized, message: "Before removing your wallet, make sure you back up your wallet".localized, preferredStyle: UIAlertController.Style.alert)
//
//        if !User.isBackupBtcWallet {
//            alertRemove.addAction(UIAlertAction(title: "Backup".localized, style: UIAlertAction.Style.default, handler: { (action) in
//            self.backup(vc: vc)
//        }))}
//
//
//        alertRemove.addAction(UIAlertAction(title: "Remove".localized, style: UIAlertAction.Style.default, handler: { (action) in
//            let keychain = Keychain()
//            keychain.delete(for: "seed_\(String(describing: User.currentUser.id))")
//            self.stopSync()
//            self.wallet = nil
//        }))
//
//        DispatchQueue.main.async {
//            vc.present(alertRemove, animated: true) {
//                () -> Void in
//            }
//        }
//    }
//
//    func backup(vc: UIViewController) {
//        guard let backupViewController = StoryBoard.bitcoin.instantiateViewController(withIdentifier: VCIdentifier.backupBtcWalletViewController) as? BackupBtcWalletViewController else {return}
//
//        vc.navigationController?.pushViewController(backupViewController, animated: true)
//    }
//
//    func restoreBySeed(seed: Data, vc: UIViewController) {
//        let keychain = Keychain()
//        keychain.set(seed, for: "seed_\(String(describing: User.currentUser.id))")
//        self.wallet = HDWallet(seed: seed, network: network)
//
//    }
//
//    func updateTxHistory() {
//        var payments = [Payment]()
//        for address in self.usedAddresses() {
//            PeerGroup.queue.addOperation {
//                let blockStore = try! SQLiteBlockStore.default()
//
//                let newPayments = try! blockStore.transactions(address: address)
//                for p in newPayments where !payments.contains(p){
//                    payments.append(p)
//                }
//                DispatchQueue.main.async {
//                    self.transactions = payments
//                }
//            }
//        }
//    }
//
//    func updateBalance() {
//        PeerGroup.uiQueue.addOperation {
//
//            let blockStore = try! SQLiteBlockStore.default()
//
//            var balance: Int64 = 0
//            for address in self.usedAddresses() {
//                balance += try! blockStore.calculateBalance(address: address)
//            }
//            CryptoManager.shared.btcInfoIsLoaded = true
//
//            self.balance = Decimal(balance) / Decimal(100000000)
//            self.balanceSatoshi = Decimal(balance)
//            print("satoshi balance \(balance)")
//
//            self.fiatBalance = self.balance * self.course
//            self.updateTxHistory()
//
//            if balance != 0 {
//                self.stopSync()
//            }
//        }
//        PeerGroup.uiQueue.waitUntilAllOperationsAreFinished()
//    }
//
//    func setPublicKey() {
//        let address = try! self.wallet!.receiveAddress(index: self.externalIndex)
//        self.publicKey = address.base58
//    }
//
//    public func peerGroupDidStop(_ peerGroup: PeerGroup) {
//        peerGroup.delegate = nil
//        self.peerGroup = nil
//    }
//
//    public func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup) {
//            self.updateBalance()
//
//    }
//
//    private func usedAddresses() -> [Address] {
//        var addresses = [Address]()
//        guard let wallet = self.wallet else {
//            return []
//        }
//        for index in 0..<(self.externalIndex + 20) {
//            if let address = try? wallet.receiveAddress(index: index) {
//                addresses.append(address)
//            }
//        }
//        for index in 0..<(self.internalIndex + 20) {
//            if let address = try? wallet.changeAddress(index: index) {
//                addresses.append(address)
//            }
//        }
//        return addresses
//    }
//
//    private func usedKeys() -> [PrivateKey] {
//        var keys = [PrivateKey]()
//        guard let wallet = self.wallet else {
//            return []
//        }
//        // Receive key
//        for index in 0..<(self.externalIndex + 20) {
//            if let key = try? wallet.privateKey(index: index) {
//                keys.append(key)
//            }
//        }
//        // Change key
//        for index in 0..<(self.internalIndex + 20) {
//            if let key = try? wallet.changePrivateKey(index: index) {
//                keys.append(key)
//            }
//        }
//
//        return keys
//    }
//
//    func startSync() {
//        print("start sync")
//
//        PeerGroup.queue.addOperation {
//            let blockStore = try! SQLiteBlockStore.default()
//            let blockChain = BlockChain(network: self.network, blockStore: blockStore)
//
//            self.peerGroup = PeerGroup(blockChain: blockChain)
//            self.peerGroup?.delegate = self
//            print("Blockchain \(String(describing: self.peerGroup?.blockChain.latestBlockHash().base64EncodedString()))")
//
//            for address in self.usedAddresses() {
//                if let publicKey = address.publicKey {
//                    self.peerGroup?.addFilter(publicKey)
//                }
//                self.peerGroup?.addFilter(address.data)
//            }
//
//            DispatchQueue.main.async {
//                self.peerGroup?.start()
//            }
//        }
//    }
//
//    func stopSync() {
//        print("stop sync")
//        peerGroup?.stop()
//    }
//
//    var internalIndex: UInt32 {
//        set {
//            UserDefaults.standard.set(Int(newValue), forKey: #function)
//        }
//        get {
//            return UInt32(UserDefaults.standard.integer(forKey: #function))
//        }
//    }
//    var externalIndex: UInt32 {
//        set {
//            UserDefaults.standard.set(Int(newValue), forKey: #function)
//        }
//        get {
//            return UInt32(UserDefaults.standard.integer(forKey: #function))
//        }
//    }
//
//    func checkPasswordWallet(vc: UIViewController, completionHandler: @escaping (Bool) -> ()) {
//        print(User.passwordBtcWallet)
//        let alertCheckPassword = UIAlertController(title: "Security password".localized, message: "Enter the password that was specified when creating or restoring the wallet".localized, preferredStyle: UIAlertController.Style.alert)
//
//        alertCheckPassword.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: nil))
//        alertCheckPassword.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { (nil) in
//            let textField = alertCheckPassword.textFields![0] as UITextField
//            if User.passwordBtcWallet == textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
//                completionHandler(true)
//            } else {
//                completionHandler(false)
//            }
//        }))
//        alertCheckPassword.addTextField { (textField) in
//            textField.placeholder = "Enter security password".localized
//            textField.isSecureTextEntry = true
//        }
//
//        DispatchQueue.main.async {
//            vc.present(alertCheckPassword, animated: true) {
//                () -> Void in
//            }
//        }
//    }
//
//    func getUnspentTransactions() {
//        let blockStore = try! SQLiteBlockStore.default()
//
//        unspentTransactions = []
//        for address in usedAddresses() {
//            unspentTransactions.append(contentsOf: try! blockStore.unspentTransactions(address: address))
//        }
//    }
//
//    func sendToSomeAddress(amount: Int64, fee: Int64, toAddress: String, vc : UIViewController) {
//        var address : Address
//        do {
//            address = try AddressFactory.create(toAddress)
//        } catch BitcoinKit.AddressError.invalid {
//            print("Invalid format private key")
//            _ = SimpleOkAlertController.init(title: "Transaction".localized, message: "You entered an incorrect address".localized, vc: vc)
//            return
//        } catch {
//            print("Some error")
//            return
//        }
//
//        let changeAddress: Address = try! self.wallet!.changeAddress()
//
//        var utxos: [UnspentTransaction] = []
//        for p in self.unspentTransactions {
//            let value = p.amount
//            let lockScript = Script.buildPublicKeyHashOut(pubKeyHash: p.to.data)
//            let txHash = Data(p.txid.reversed())
//            let txIndex = UInt32(p.index)
//            print(p.txid.hex, txIndex, lockScript.hex, value)
//
//            let unspentOutput = TransactionOutput(value: value, lockingScript: lockScript)
//            let unspentOutpoint = TransactionOutPoint(hash: txHash, index: txIndex)
//            let utxo = UnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
//            utxos.append(utxo)
//        }
//
//        let unsignedTx = createUnsignedTx(toAddress: address, amount: amount, fee: fee, changeAddress: changeAddress, utxos: utxos)
//        let signedTx = signTx(unsignedTx: unsignedTx, keys: usedKeys())
//
//        peerGroup?.sendTransaction(transaction: signedTx)
//    }
//
//    public func selectTx(from utxos: [UnspentTransaction], amount: Int64) -> [UnspentTransaction] {
//        return utxos
//    }
//
//    public func createUnsignedTx(toAddress: Address, amount: Int64, fee: Int64, changeAddress: Address, utxos: [UnspentTransaction]) -> UnsignedTransaction {
//        let utxos = selectTx(from: utxos, amount: amount)
//        let totalAmount: Int64 = Int64(truncating: NSDecimalNumber(decimal: BitcoinManager.shared.balanceSatoshi))
//        print("create transaction total amount: \(totalAmount)")
//
//        print("Fee \(fee)")
//        let change: Int64 = totalAmount - amount - fee
//        print("change: \(change)")
//
//        let toPubKeyHash: Data = toAddress.data
//        let changePubkeyHash: Data = changeAddress.data
//
//        let lockingScriptTo = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
//        let lockingScriptChange = Script.buildPublicKeyHashOut(pubKeyHash: changePubkeyHash)
//
//        let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo)
//        let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange)
//
//        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
//        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
//        return UnsignedTransaction(tx: tx, utxos: utxos)
//    }
//
//    public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
//        var inputsToSign = unsignedTx.tx.inputs
//        var transactionToSign: Transaction {
//            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
//        }
//
//        // Signing
//        let hashType = SighashType.BTC.ALL
//        for (i, utxo) in unsignedTx.utxos.enumerated() {
//            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
//
//            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
//            guard let key = keysOfUtxo.first else {
//                continue
//            }
//
//            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BTC.ALL)
//            let signature: Data = try! Crypto.sign(sighash, privateKey: key)
//            let txin = inputsToSign[i]
//            let pubkey = key.publicKey()
//
//            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
//
//            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
//        }
//        return transactionToSign
//    }
}
