//
//  BitcoinWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 24.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class BitcoinWalletViewController: PaymonViewController {
    
    @IBOutlet weak var tableTransactionsView: WalletTableInfoUIView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var fiatSymbol: UILabel!
    
    @IBOutlet weak var cryptoBalance: UILabel!
    
    @IBOutlet weak var fiatBalance: UILabel!
    private var walletWasCreated: NSObjectProtocol!
    private var updateBtcBalance: NSObjectProtocol!
    
    var privateKey : String!
    var publicKey : String!

    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func qrCodeClick(_ sender: Any) {
        let keysMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        let privateKey = UIAlertAction(title: "Private key".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            
            BitcoinManager.shared.checkPasswordWallet(vc: self, completionHandler: { (isSuccess:Bool) in
                if isSuccess {
                    guard let keysViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
                    
                    //TODO: Set private key here
                    keysViewController.keyValue = self.privateKey
                    
                    self.present(keysViewController, animated: true, completion: nil)
                } else {
                    _ = SimpleOkAlertController.init(title: "Security password".localized, message: "Incorrect password".localized, vc: self)
                }
            })
        })
        
        let publicKey = UIAlertAction(title: "Public key".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let keysViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
            
            //TODO: Set public key here
            keysViewController.keyValue = self.publicKey
            
            self.present(keysViewController, animated: true, completion: nil)
        })
        
        keysMenu.addAction(cancel)
        keysMenu.addAction(publicKey)
        keysMenu.addAction(privateKey)
        
        self.present(keysMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func funcsClick(_ sender: Any) {
        let funcsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            BitcoinManager.shared.deleteWallet(vc: self)
        })
        
        let backup = UIAlertAction(title: "Backup".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            BitcoinManager.shared.backup(vc: self)
        })
        let recovery = UIAlertAction(title: "Recovery".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            BitcoinManager.shared.restoreByPrivateKey(vc: self)
        })
        
        funcsMenu.addAction(cancel)
        funcsMenu.addAction(recovery)
        funcsMenu.addAction(backup)
        funcsMenu.addAction(delete)
    
        self.present(funcsMenu, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        
        setLayoutOptions()
        getWalletInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        walletWasCreated = NotificationCenter.default.addObserver(forName: .walletWasCreated, object: nil, queue: nil) {
            notification in
            self.dismiss(animated: true, completion: nil)
        }
        
        updateBtcBalance = NotificationCenter.default.addObserver(forName: .updateBtcBalance, object: nil, queue: nil) {
            notification in
            DispatchQueue.main.async {
                self.cryptoBalance.text = String(format: "%.\(User.symbCount)f", BitcoinManager.shared.getBalance().double)
                self.fiatBalance.text = String(format: "%.2f", BitcoinManager.shared.getFiatBalance().double)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(walletWasCreated)
        NotificationCenter.default.removeObserver(updateBtcBalance)
    }
    
    func setLayoutOptions() {
        
        self.balanceView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width

        self.balanceView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.balanceView.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "Bitcoin wallet".localized
        self.backItem.title = "Back".localized

    }
    
    func getWalletInfo() {
        fiatSymbol.text = User.currencyCodeSymb
        cryptoBalance.text = String(format: "%.\(User.symbCount)f", BitcoinManager.shared.getBalance().double)
        fiatBalance.text = String(format: "%.2f", BitcoinManager.shared.getFiatBalance().double)
        privateKey = BitcoinManager.shared.wallet?.privateKey.toWIF()
        publicKey = BitcoinManager.shared.wallet?.publicKey.toLegacy().base58
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let transferViewController = segue.destination as? BitcoinTransferViewController else {return}
        transferViewController.publicKey = publicKey
    }
    
}
