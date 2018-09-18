//
//  SignUpViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 20.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class SignUpViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var login: UITextField!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var hintPassword: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var hintLogin: UILabel!
    
    @IBOutlet weak var signUpItem: UIBarButtonItem!
    
    @IBOutlet weak var topStackTextFields: UIView!
    @IBOutlet weak var stackTextFields: UIView!
    private var disableSignUpButtons: NSObjectProtocol!
    private var enableSignUpButtons: NSObjectProtocol!
    
    var canSignUp = false
    
    var loginValue = ""
    var passwordValue = ""
    var emailValue = ""
    var loginValid = false
    var passwordValid = false
    var repeatPasswordValid = false
    var emailValid = false
    
    let blueLight = UIColor.AppColor.Blue.primaryBlue.withAlphaComponent(0.15)
    let whiteLight = UIColor.white.withAlphaComponent(0.15)
    
    override func viewDidLoad() {
        
        disableSignUpButtons = NotificationCenter.default.addObserver(forName: .disableSignUpButtons, object: nil, queue: nil) {
            notification in
            
            self.updateButtons(canSignUp: false)
        }
        
        enableSignUpButtons = NotificationCenter.default.addObserver(forName: .enableSignUpButtons, object: nil, queue: nil) {
            notification in
            
            self.updateButtons(canSignUp: true)
        }
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        signUpItem.isEnabled = false
        
        login.delegate = self
        password.delegate = self
        repeatPassword.delegate = self
        email.delegate = self
        
        login.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        repeatPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        email.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        self.title = "Sign up".localized
        
        hintLogin.text = "Login length is at least 3 characters".localized
        hintPassword.text = "Password length is at least 8 characters".localized
        
        login.placeholder = "Login".localized
        password.placeholder = "Password".localized
        repeatPassword.placeholder = "Repeat password".localized
        email.placeholder = "E-mail".localized
        
        stackTextFields.layer.masksToBounds = true
        stackTextFields.layer.cornerRadius = 30
        
        topStackTextFields.layer.masksToBounds = true
        topStackTextFields.layer.cornerRadius = 30
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == login {
            password.becomeFirstResponder()
        } else if textField == password {
            repeatPassword.becomeFirstResponder()
        } else if textField == repeatPassword {
            email.becomeFirstResponder()
        } else if textField == email {
            self.signUpClick(self)
        }
        
        return true
    }
    
    @objc func textFieldDidChanged(_ textField : UITextField) {
        
        switch (textField) {
        case login:
            loginValue = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            loginValid = Utils.validateLogin(loginValue)
            textField.backgroundColor = loginValid ? blueLight : whiteLight
        case password:
            passwordValue = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            passwordValid = Utils.validatePassword(passwordValue)
            textField.backgroundColor = passwordValid ? blueLight : whiteLight
        case repeatPassword:
            repeatPasswordValid = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == passwordValue
            textField.backgroundColor = repeatPasswordValid ? blueLight : whiteLight
        case email:
            emailValue = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            emailValid = Utils.validateEmail(emailValue)
            textField.backgroundColor = emailValid ? blueLight : whiteLight
        default: print("")
        }
        
        if loginValid && passwordValid && repeatPasswordValid && emailValid {
            canSignUp = true
            updateButtons(canSignUp: canSignUp)
        } else {
            canSignUp = false
            updateButtons(canSignUp: canSignUp)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case login:
            return newLength <= 20
        case password:
            return newLength <= 96
        case repeatPassword:
            return newLength <= 96
        case email:
            return newLength <= 128
        default: print("")
        }
        
        return true
    }
    
    func updateButtons(canSignUp : Bool) {
        signUpItem.isEnabled = canSignUp
    }
    
    @IBAction func signUpClick(_ sender: Any) {
        if (canSignUp) {
            UserManager.signUpNewUser(login: loginValue, password: passwordValue, email: emailValue, viewController: self)
        }
    }
}
