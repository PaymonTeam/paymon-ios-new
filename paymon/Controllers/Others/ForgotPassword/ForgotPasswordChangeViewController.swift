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
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var stackButtons: UIView!
    
    var emailValue: String!
    var codeValue: Int32!
    
    let blueLight = UIColor.AppColor.Blue.primaryBlue.withAlphaComponent(0.15)
    let whiteLight = UIColor.white.withAlphaComponent(0.15)
    
    var password = ""
    var repeatPasswordS = ""
    
    override func viewDidLoad() {
        
        setLayoutOptions()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        newPassword.delegate = self
        repeatPassword.delegate = self
        
        newPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        repeatPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChanged(_ textField : UITextField) {
        
        switch (textField) {
        case newPassword:
            password = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            textField.backgroundColor = !password.isEmpty && password.count >= 8 ? blueLight : whiteLight
        case repeatPassword:
            repeatPasswordS = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            textField.backgroundColor = !repeatPasswordS.isEmpty && repeatPasswordS.elementsEqual(password) ? blueLight : whiteLight
        default:
            break
        }
    }
    
    func setLayoutOptions() {
        newPassword.placeholder = "New password".localized
        repeatPassword.placeholder = "Repeat password".localized
        hint.text = "Create a new password".localized
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        self.title = "Recovery password".localized
        
        stackButtons.layer.cornerRadius = 30
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendResponse() {
        self.view.endEditing(true)
        
        if password.isEmpty || password.count < 8{
            newPassword.shake()
            return
        } else if repeatPasswordS.isEmpty || !repeatPasswordS.elementsEqual(password){
            repeatPassword.shake()
            return
        } else {
           UserManager.setNewPassword(loginOrEmail: self.emailValue, code: self.codeValue, password: password, vc: self)

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
