//
//  EthereumWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 23/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import DeckTransition

class EthereumWalletViewController: PaymonViewController {
    
    @IBOutlet weak var tableTransactionsView: WalletTableInfoUIView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var fiatSymbol: UILabel!
    
    @IBOutlet weak var cryptoBalance: UILabel!
    
    @IBOutlet weak var fiatBalance: UILabel!
    private var walletWasCreated: NSObjectProtocol!
    private var updateBalance: NSObjectProtocol!
    @IBOutlet weak var needBackUp: UIButton!
    @IBOutlet weak var needBackUpHeight: NSLayoutConstraint!
    
    var publicKey : String!
    
    @IBOutlet weak var backItem: UIBarButtonItem!
    
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func needBackUpClick(_ sender: Any) {
        self.showBackupWallet()
    }
    
    func showBackupWallet() {
        guard let backupViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.backupEthWalletViewController) as? BackupEthWalletViewController else {return}
        
        self.navigationController?.pushViewController(backupViewController, animated: true)
    }
    
    @IBAction func qrCodeClick(_ sender: Any) {
        guard let keysViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
        keysViewController.keyValue = self.publicKey
        keysViewController.currency = Money.eth
        
        let transitionDelegate = DeckTransitioningDelegate()
        keysViewController.transitioningDelegate = transitionDelegate
        keysViewController.modalPresentationStyle = .custom
        present(keysViewController, animated: true, completion: nil)
    }
    
    @IBAction func funcsClick(_ sender: Any) {
        let funcsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let backup = UIAlertAction(title: "Backup".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showBackupWallet()
        })
        let delete = UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            
            let alertRemove = UIAlertController(title: "Remove wallet".localized, message: "Before removing your wallet, make sure you back up your wallet".localized, preferredStyle: UIAlertController.Style.alert)
            
            if !User.isBackupEthWallet {
                alertRemove.addAction(UIAlertAction(title: "Backup".localized, style: .default, handler: { (action) in
                    self.showBackupWallet()
                }))}
            
            alertRemove.addAction(UIAlertAction(title: "Remove".localized, style: .default, handler: { (action) in
                EthereumManager.shared.deleteWallet() { isDeleted in
                    if isDeleted {
                        //TODO: добавить ввод пароля
                        User.deleteEthWallet()
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        _ = SimpleOkAlertController.init(title: "Remove wallet".localized, message: "Failed to delete wallet. Try later.".localized, vc: self)
                    }
                }
            }))
            alertRemove.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alertRemove, animated: true) {
                    () -> Void in
                }
            }
        })
        
        
        let recovery = UIAlertAction(title: "Recovery".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let restoreEthViewController = StoryBoard.ethereum.instantiateViewController(withIdentifier: VCIdentifier.restoreEthViewController) as? RestoreEthViewController else {return}
            self.navigationController?.pushViewController(restoreEthViewController, animated: true)
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
        
        if fiatSymbol != nil {
            getWalletInfo()
        }
        
        if needBackUp != nil {
            self.needBackUpHeight.constant = !User.isBackupEthWallet ? 40 : 0
        }
        
        walletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in
            self.dismiss(animated: true, completion: nil)
        }
        
        updateBalance = NotificationCenter.default.addObserver(forName: .updateBalance, object: nil, queue: nil) {
            notification in
            DispatchQueue.main.async {
                self.cryptoBalance.text = String(format: "%.\(User.symbCount)f", EthereumManager.shared.cryptoBalance)
                self.fiatBalance.text = String(format: "%.2f", EthereumManager.shared.fiatBalance)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(walletWasCreated)
        NotificationCenter.default.removeObserver(updateBalance)
    }
    
    func setLayoutOptions() {
        
        self.balanceView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width
        
        self.balanceView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.balanceView.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "Ethereum wallet".localized
        self.backItem.title = "Back".localized
        self.needBackUp.layer.cornerRadius = needBackUp.frame.height/2
        self.needBackUp.setTitle("We strongly recommend making a backup!".localized, for: .normal)
        self.needBackUp.titleLabel?.numberOfLines = 0
        self.needBackUp.titleLabel?.textAlignment = .center
        self.needBackUp.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.needBackUp.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.needBackUp.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.needBackUpHeight.constant = !User.isBackupBtcWallet ? 40 : 0
        
    }
    
    func getWalletInfo() {
        DispatchQueue.main.async {
            self.fiatSymbol.text = User.currencyCodeSymb
            self.cryptoBalance.text = String(format: "%.\(User.symbCount)f", EthereumManager.shared.cryptoBalance)
            self.fiatBalance.text = String(format: "%.2f", EthereumManager.shared.fiatBalance)
        }
        publicKey = EthereumManager.shared.sender?.address
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let transferViewController = segue.destination as? EthereumTransferViewController else {return}
        transferViewController.publicKey = publicKey
    }
    
    @IBAction func unWindToFinance(_ segue: UIStoryboardSegue) {
        
    }
}
