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
    @IBOutlet weak var needBackUp: UIButton!
    @IBOutlet weak var needBackUpHeight: NSLayoutConstraint!
    
    var publicKey : String!

    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func needBackUpClick(_ sender: Any) {
        guard let backupViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.backupBtcWalletViewController) as? BackupBtcWalletViewController else {return}
        
        self.navigationController?.pushViewController(backupViewController, animated: true)
    }
    
    @IBAction func qrCodeClick(_ sender: Any) {
        guard let keysViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
        keysViewController.keyValue = self.publicKey
        self.present(keysViewController, animated: true, completion: nil)
    }
    
    @IBAction func funcsClick(_ sender: Any) {
        let funcsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
//            BitcoinManager.shared.deleteWallet(vc: self)
        })
        
        
        let recovery = UIAlertAction(title: "Recovery".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let restoreBtcViewController = StoryBoard.bitcoin.instantiateViewController(withIdentifier: VCIdentifier.restoreBtcViewController) as? RestoreBtcViewController else {return}
            self.navigationController?.pushViewController(restoreBtcViewController, animated: true)
        })
        
        funcsMenu.addAction(cancel)
        funcsMenu.addAction(recovery)
        if !User.isBackupBtcWallet {
            let backup = UIAlertAction(title: "Backup".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                guard let backupViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.backupBtcWalletViewController) as? BackupBtcWalletViewController else {return}
                
                self.navigationController?.pushViewController(backupViewController, animated: true)
                
            })
            funcsMenu.addAction(backup)
        }
        funcsMenu.addAction(delete)
        
    
        self.present(funcsMenu, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        
        setLayoutOptions()
        getWalletInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if needBackUp != nil {
            self.needBackUpHeight.constant = !User.isBackupBtcWallet ? 40 : 0
        }
        
        walletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in
            self.dismiss(animated: true, completion: nil)
        }
        
        updateBtcBalance = NotificationCenter.default.addObserver(forName: .updateBalance, object: nil, queue: nil) {
            notification in
            DispatchQueue.main.async {
                self.cryptoBalance.text = String(format: "%.\(User.symbCount)f", BitcoinManager.shared.balance.double)
                self.fiatBalance.text = String(format: "%.2f", BitcoinManager.shared.fiatBalance.double)
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
        self.needBackUp.layer.cornerRadius = needBackUp.frame.height/2
        self.needBackUp.setTitle("We strongly recommend making a backup".localized, for: .normal)

        self.needBackUp.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.needBackUp.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.needBackUpHeight.constant = !User.isBackupBtcWallet ? 40 : 0

    }
    
    func getWalletInfo() {
//        BitcoinManager.shared.updateBalance()
        fiatSymbol.text = User.currencyCodeSymb
        cryptoBalance.text = String(format: "%.\(User.symbCount)f", BitcoinManager.shared.balance.double)
        fiatBalance.text = String(format: "%.2f", BitcoinManager.shared.fiatBalance.double)
        publicKey = BitcoinManager.shared.publicKey
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let transferViewController = segue.destination as? BitcoinTransferViewController else {return}
        transferViewController.publicKey = publicKey
    }
    
}
