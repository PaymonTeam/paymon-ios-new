//
//  BackupBtcWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 10/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class BackupBtcWalletViewController: UIViewController {
    
    @IBOutlet weak var seedHint: UILabel!
    @IBOutlet weak var labelsView: UIView!
    @IBOutlet var mnemonicLabels: [UILabel]!
    @IBOutlet weak var backup: UIButton!

    @objc func copySeed(_ sender: UITapGestureRecognizer) {
        UIPasteboard.general.string = User.rowSeed
        _ = SimpleOkAlertController.init(title: "Seed".localized, message: "The passphrase was copied to the clipboard".localized, vc: self)
    }
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.copySeed(_:)))
        tap.cancelsTouchesInView = false
        labelsView.addGestureRecognizer(tap)
        
        let words = User.rowSeed.split(separator: " ")
        for (words, label) in zip(words, mnemonicLabels) {
            label.text = String(words)
        }
        
        setLayoutOptions()
    }
    
    @IBAction func backupClick(_ sender: Any) {
        User.backUpBtcWallet()
        navigationController?.popViewController(animated: true)
    }
    
    func setLayoutOptions() {

        seedHint.text = "Please write down and save the passphrase of 12 words. The code phrase is needed to restore the wallet.".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "Backup".localized
        backup.setTitle("I saved the passphrase".localized, for: .normal)
        backup.layer.cornerRadius = backup.frame.height/2
        labelsView.layer.cornerRadius = 30
        
    }
    
}
