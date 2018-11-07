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
    
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var stackViews: UIView!
    
    var password : String! = ""
    var repeatPasswordString: String! = ""
    var isRestore = false
    @IBOutlet weak var hint: UILabel!
    
    private var walletWasCreated: NSObjectProtocol!
    
    override func viewDidLoad() {
        walletWasCreated = NotificationCenter.default.addObserver(forName: .walletWasCreated, object: nil, queue: nil) {
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
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "New Bitcoin wallet".localized
        
        stackViews.layer.cornerRadius = 30
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
    
        if !isRestore {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
            BitcoinManager.shared.createBtcWallet(password: password)
        } else {
            BitcoinManager.shared.restoreByPrivateKey(vc: self)
        }
    }
    
    func walletCreated() {
        User.savePasswordWallet(password: password)
        MBProgressHUD.hide(for: self.view, animated: true)
        navigationController?.popViewController(animated: true)
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
