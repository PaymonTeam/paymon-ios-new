//
//  SignUpViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 20.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var hintTitle: UILabel!
    @IBOutlet weak var login: UITextField!
    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var hintPassword: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var hintLogin: UILabel!
    
    @IBOutlet weak var signUpItem: UIBarButtonItem!
    @IBOutlet weak var backArrow: UIBarButtonItem!
    
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
    
    @IBAction func arrowBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        disableSignUpButtons = NotificationCenter.default.addObserver(forName: .disableSignUpButtons, object: nil, queue: nil) {
            notification in
            
            self.updateButtons(canSignUp: false)
        }
        
        enableSignUpButtons = NotificationCenter.default.addObserver(forName: .enableSignUpButtons, object: nil, queue: nil) {
            notification in
            
            self.updateButtons(canSignUp: true)
        }
    }
    
    override func viewDidLoad() {
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        signUpItem.isEnabled = false
        signUp.isEnabled = false
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.topItem?.title = "Sign up".localized
        
        hintTitle.text = "Please enter your information".localized
        hintLogin.text = "Login length is at least 3 characters".localized
        hintPassword.text = "Password length is at least 8 characters".localized
        
        login.placeholder = "Login".localized
        password.placeholder = "Password".localized
        repeatPassword.placeholder = "Repeat password".localized
        email.placeholder = "E-mail".localized
    
        signUp.setTitle("Go".localized, for: .normal)
        
        login.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        repeatPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        email.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        
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
    
    func updateButtons(canSignUp : Bool) {
        signUpItem.isEnabled = canSignUp
        signUp.isEnabled = canSignUp
        signUp.backgroundColor = canSignUp ? blueLight : whiteLight
    }
    
    @IBAction func signUpClick(_ sender: Any) {
        if (canSignUp) {
            UserManager.signUpNewUser(login: loginValue, password: passwordValue, email: emailValue, viewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(disableSignUpButtons)
        NotificationCenter.default.removeObserver(enableSignUpButtons)
    }
}
