//
//  CreateNewBtcWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 31/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class CreateNewBtcWalletViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var seedHint: UILabel!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var stackViews: UIView!
    @IBOutlet weak var labelsView: UIView!
    
    var mnemonic: [String]!
    var rowForBackup : String! = ""
    @IBOutlet var mnemonicLabels: [UILabel]!
    
    var password : String! = ""
    var repeatPasswordString: String! = ""

    @IBOutlet weak var hint: UILabel!
    
    private var walletWasCreated: NSObjectProtocol!
    
    @objc func copySeed(_ sender: UITapGestureRecognizer) {
        UIPasteboard.general.string = rowForBackup
        _ = SimpleOkAlertController.init(title: "Seed".localized, message: "The passphrase was copied to the clipboard".localized, vc: self)
    }
    
    override func viewDidLoad() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.copySeed(_:)))
        tap.cancelsTouchesInView = false
        labelsView.addGestureRecognizer(tap)
        
//        do {
//            self.mnemonic = try Mnemonic.generate()
//            for word in mnemonic {
//                rowForBackup.append(word)
//                rowForBackup.append(" ")
//            }
//            for (mnemonic, label) in zip(mnemonic, mnemonicLabels) {
//                label.text = mnemonic
//            }
//        } catch {
//            _ = SimpleOkAlertController.init(title: "New Bitcoin wallet".localized, message: "Failed to generate random seed. Please try again later".localized, vc: self)
//        }
        
        walletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in
            self.walletCreated()
        }
        newPassword.delegate = self
        repeatPassword.delegate = self
        setLayoutOptions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(walletWasCreated)
    }
    
    func setLayoutOptions() {
        newPassword.placeholder = "New password".localized
        repeatPassword.placeholder = "Repeat password".localized
        hint.text = "Create a password for new Bitcoin wallet".localized
        seedHint.text = "Please write down and save the passphrase of 12 words. The code phrase is needed to restore the wallet.".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "New Bitcoin wallet".localized
        
        stackViews.layer.cornerRadius = 30
        labelsView.layer.cornerRadius = 30

    }
    
    @IBAction func createWallet(_ sender: Any) {
       
        password = newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        repeatPasswordString = repeatPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if password.isEmpty {
            newPassword.shake()
            return
        }
        
        if repeatPasswordString.isEmpty {
            repeatPassword.shake()
            return
        }
        
        if repeatPasswordString != password {
            repeatPassword.shake()
            return
        }
    
        DispatchQueue.main.async {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
//        let seed = Mnemonic.seed(mnemonic: mnemonic)
//        BitcoinManager.shared.importWallet(seed: seed)
    }
    
    func walletCreated() {
        User.saveBtcPasswordWallet(password: password)
        User.saveSeed(rowSeed: rowForBackup)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case newPassword:
            return newLength <= 96
        case repeatPassword:
            return newLength <= 96
        default: break
        }
        
        return true
    }
}
