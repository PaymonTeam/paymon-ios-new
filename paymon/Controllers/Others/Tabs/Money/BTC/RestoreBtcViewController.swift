//
//  RestoreBtcViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 13/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import MBProgressHUD

class RestoreBtcViewController: UIViewController {
    
    @IBOutlet weak var viewPassphrase: UIView!
    @IBOutlet weak var restore: UIButton!
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var passwordHint: UILabel!
    @IBOutlet weak var passphrase: UITextView!
    
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var passwordView: UIView!
    
    var password : String! = ""
    var repeatPasswordString: String! = ""
    var rowForRestore : String! = ""
    var mnemonic: [String]! = []
    
    private var walletWasCreated: NSObjectProtocol!
    
    override func viewDidLoad() {
        setLayoutOptions()
        
//        walletWasCreated = NotificationCenter.default.addObserver(forName: , object: nil, queue: nil) {
//            notification in
//            self.walletWasRestore()
//        }
        
        passphrase.delegate = self
    }
    
    func setLayoutOptions() {
        
        hint.text = "Enter the passphrase from the wallet you want to restore".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "Restore wallet".localized
        passphrase.text = "Enter passphrase".localized
        passphrase.textColor = UIColor.white.withAlphaComponent(0.4)
        passwordHint.text = "Create a new password".localized
    
        restore.setTitle("Restore".localized, for: .normal)
        restore.layer.cornerRadius = restore.frame.height/2
        passwordView.layer.cornerRadius = 30
        viewPassphrase.layer.cornerRadius = 30
        
    }
    
    @IBAction func restoreClick(_ sender: Any) {
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
        
        rowForRestore = passphrase.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !rowForRestore.isEmpty {
            let words = rowForRestore.split(separator: " ")
            if words.count < 12 || words.count > 12 {
                _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "The passphrase should consist of 12 words".localized, vc: self)
            } else {
                for word in words {
                    mnemonic.append(String(word))
                }
                
                DispatchQueue.main.async {
                    let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
                }
//                let seed = Mnemonic.seed(mnemonic: mnemonic)
//                BitcoinManager.shared.restoreBySeed(seed: seed, vc: self)
            }
        } else {
            passphrase.shake()
        }
        
        
    }
    
    func walletWasRestore() {
        User.saveBtcPasswordWallet(password: password)
        User.saveSeed(rowSeed: rowForRestore)
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension RestoreBtcViewController: UITextViewDelegate {
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        
//        if textView.textColor == UIColor.white.withAlphaComponent(0.4) {
//            textView.text = ""
//            textView.textColor = UIColor.white.withAlphaComponent(0.8)
//        }
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Enter passphrase".localized
//            textView.textColor = UIColor.white.withAlphaComponent(0.4)
//        }
//    }
}
