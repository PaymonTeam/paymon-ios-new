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
            
            guard let keysViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
            
            //TODO: Set private key here
            keysViewController.keyValue = self.privateKey
            
            self.present(keysViewController, animated: true, completion: nil)
            
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
            //TODO: Add Delete wallet func
        })
        
        let backup = UIAlertAction(title: "Backup".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //TODO: Add Backup wallet func
        })
        let recovery = UIAlertAction(title: "Recovery".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //TODO: Add Recovery wallet func
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
    
    func setLayoutOptions() {
        
        self.balanceView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width

        self.balanceView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.balanceView.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "Bitcoin wallet".localized
        self.backItem.title = "Back".localized

    }
    
    func getWalletInfo() {
        //get Bitcoin wallet info (Balance(crypto and fiat), Private and Public Keys)
        
        // cryptoBalance =
        // fiatBalance =
        // privateKey =
        // publicKey =
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let transferViewController = segue.destination as? BitcoinTransferViewController else {return}
        
        let localLang = Locale.current.languageCode
        if localLang != nil {
            if localLang! == "ru" {
                transferViewController.fiatCurrancy = Money.rub
            } else {
                transferViewController.fiatCurrancy = Money.usd
            }
        }
    }
    
}
