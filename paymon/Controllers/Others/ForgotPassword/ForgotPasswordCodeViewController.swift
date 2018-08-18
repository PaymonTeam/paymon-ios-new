//
//  ForgotPasswordCodeViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class ForgotPasswordCodeViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var nextItem: UIBarButtonItem!
    @IBOutlet weak var recoveryCode: UITextField!
    @IBOutlet weak var hint: UILabel!
    
    var emailValue : String!
    
    override func viewDidLoad() {
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Recovery password".localized
        
        recoveryCode.delegate = self
        recoveryCode.placeholder = "Recovery code".localized
        hint.text = "Please enter the recovery code that was sent to you to e-mail".localized
        nextItem.title = "Next".localized
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendResponse() {
        //TODO: send code response function
        self.view.endEditing(true)
        
        guard let code = recoveryCode.text else {
            return
        }
        
        if code.isEmpty {
            recoveryCode.shake()
            return
        } else {
            UserManager.verifyRecoveryCode(loginOrEmail: self.emailValue, code: Int32(code)!, vc: self)
        }
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case recoveryCode:
            return newLength <= 10
        default: print("")
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let changeViewController = segue.destination as? ForgotPasswordChangeViewController else {return}
        changeViewController.emailValue = self.emailValue
        changeViewController.codeValue = self.recoveryCode.text!
    }
    
    @IBAction func arrowBackItemClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unWindForgotPasswordCode(_ segue: UIStoryboardSegue) {
        
    }
}
