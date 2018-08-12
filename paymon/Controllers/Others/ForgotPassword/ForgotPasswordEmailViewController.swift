//
//  ForgotPasswordEmailViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class ForgotPasswordEmailViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var loginOrEmail: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var sendItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Recovery password".localized
        
        loginOrEmail.placeholder = "Login or email".localized
        hint.text = "Please enter your login or email".localized
        sendItem.title = "Send".localized
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        loginOrEmail.delegate = self
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
            UserManager.sendCodeRecoveryToEmail(vc: self, loginOrEmail: loginOrEmailString)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let codeViewController = segue.destination as? ForgotPasswordCodeViewController else {return}
        codeViewController.emailValue = self.loginOrEmail.text!
    }
    
    @IBAction func arrowBackItemClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case loginOrEmail:
            return newLength <= 128
        default: print("")
        }
        
        return true
    }

    
    @IBAction func unWindForgotPasswordEmail(_ segue: UIStoryboardSegue) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendResponse()
        return true
    }
}
