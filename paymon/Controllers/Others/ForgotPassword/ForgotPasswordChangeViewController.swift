//
//  ForgotPasswordChangeViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class ForgotPasswordChangeViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var changeItem: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var hint: UILabel!
    
    var emailValue: String!
    var codeValue: String!
    
    override func viewDidLoad() {
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Recovery password".localized
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        newPassword.placeholder = "New password".localized
        repeatPassword.placeholder = "Repeat password".localized
        hint.text = "Create a new password".localized
        
        newPassword.delegate = self
        repeatPassword.delegate = self
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendResponse() {
        self.view.endEditing(true)

        guard let password = newPassword.text else {
            return
        }
        
        guard let repeatPasswordS = repeatPassword.text else {
            return
        }
        
        if password.isEmpty || password.count < 8{
            newPassword.shake()
            return
        } else if repeatPasswordS.isEmpty || !repeatPasswordS.elementsEqual(password){
            repeatPassword.shake()
            return
        } else {
           UserManager.setNewPassword(loginOrEmail: self.emailValue, code: Int32(self.codeValue)!, password: password, vc: self)

        }
        
    }
    
    @IBAction func arrowBackItemClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPassword {
            repeatPassword.becomeFirstResponder()
        } else if textField == repeatPassword {
            self.sendResponse()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case newPassword:
            return newLength <= 96
        case repeatPassword:
            return newLength <= 96
        default: print("")
        }
        
        return true
    }
}
