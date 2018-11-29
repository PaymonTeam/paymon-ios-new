//
//  ForgotPasswordEmailViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import MBProgressHUD

class ForgotPasswordEmailViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginOrEmail: UITextField!
    @IBOutlet weak var sendItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        setLayoutOptions()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        loginOrEmail.delegate = self
    }
    
    func setLayoutOptions() {
        loginOrEmail.layer.cornerRadius = loginOrEmail.frame.height/2
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        self.title = "Recovery password".localized
        
        loginOrEmail.placeholder = "Login or email".localized
        sendItem.title = "Send".localized
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendResponse() {
        //TODO: send response function
        
        self.view.endEditing(true)

        guard let loginOrEmailString = loginOrEmail.text else {
            return
        }
        
        if loginOrEmailString.isEmpty || loginOrEmailString.count < 3 {
            loginOrEmail.shake()
            return
        } else {
            DispatchQueue.main.async {
                let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            UserManager.shared.sendCodeRecoveryToEmail(loginOrEmail: loginOrEmailString) { isSent, error in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                if isSent {
                    let forgotPasswordCodeViewController = StoryBoard.forgotPassword.instantiateViewController(withIdentifier: VCIdentifier.forgotPasswordCodeViewController) as! ForgotPasswordCodeViewController
                    
                    forgotPasswordCodeViewController.emailValue = loginOrEmailString
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(forgotPasswordCodeViewController, animated: true)
                    }
                } else {
                    if error == 27 {
                        _ = SimpleOkAlertController.init(title: "Recovery password".localized, message: "This login or e-mail address is not exist".localized, vc: self)
                    } else {
                        _ = SimpleOkAlertController.init(title: "Recovery password".localized, message: "An error occurred while sending the recovery code".localized, vc: self)
                    }
                }
            }
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let codeViewController = segue.destination as? ForgotPasswordCodeViewController else {return}
//        codeViewController.emailValue = self.loginOrEmail.text!
//    }
    
    @IBAction func arrowBackItemClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case loginOrEmail:
            return newLength <= 128
        default: break
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendResponse()
        return true
    }
}
