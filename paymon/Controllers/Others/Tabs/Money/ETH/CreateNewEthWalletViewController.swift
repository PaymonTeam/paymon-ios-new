//
//  CreateNewEthWalletViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 22/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class CreateNewEthWalletViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var stackViews: UIView!
    @IBOutlet weak var passwordHint: UILabel!
    
    var password : String! = ""
    var repeatPasswordString: String! = ""
    
    private var ethwalletWasCreated: NSObjectProtocol!
    
    override func viewDidLoad() {

        ethwalletWasCreated = NotificationCenter.default.addObserver(forName: .ethWalletWasCreated, object: nil, queue: nil) {
            notification in
            self.walletCreated()
        }
        newPassword.delegate = self
        repeatPassword.delegate = self
        setLayoutOptions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(ethwalletWasCreated)
    }
    
    func setLayoutOptions() {
        newPassword.placeholder = "New password".localized
        repeatPassword.placeholder = "Repeat password".localized
        passwordHint.text = "Create a password for new Ethereum wallet".localized
        hint.text = "Use this password when recovering your wallet and when sending tokens".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "New Ethereum wallet".localized
        
        stackViews.layer.cornerRadius = 30
        
    }
    
    @IBAction func createWallet(_ sender: Any) {
        
        password = newPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        repeatPasswordString = repeatPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if password.isEmpty {
            newPassword.shake()
            return
        }
        
        if repeatPasswordString.isEmpty || repeatPasswordString != password {
            repeatPassword.shake()
            return
        }
        
        DispatchQueue.main.async {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        EthereumManager.shared.createWallet(password: password)
        
    }
    
    func walletCreated() {
        DispatchQueue.main.async {
            User.saveEthPasswordWallet(password: self.password)
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
