//
//  SignInViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 21.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import MBProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var signInItem: UIBarButtonItem!
    @IBOutlet weak var arrowBack: UIBarButtonItem!
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordForgot: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signInBottomConstraint: NSLayoutConstraint!
    
    
    @IBAction func passwordForgotClick(_ sender: Any) {
        let forgotPasswordEmailViewController = StoryBoard.forgotPassword.instantiateViewController(withIdentifier: VCIdentifier.forgotPasswordEmailViewController) as! ForgotPasswordEmailViewController
        
        DispatchQueue.main.async {
            self.present(forgotPasswordEmailViewController, animated: true)
        }
    }
    
    @IBAction func arrowBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInClick(_ sender: Any) {
        if (login.text?.isEmpty)! {
            login.shake()
            return
        } else if (password.text?.isEmpty)! {
            password.shake()
            return
        } else {
            self.view.endEditing(true)
            UserManager.signIn(login: (login.text?.trimmingCharacters(in: .whitespacesAndNewlines))!, password: (password.text?.trimmingCharacters(in: .whitespacesAndNewlines))!, vc: self)
        }
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        login.delegate = self
        password.delegate = self
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Sign in".localized
        
        login.placeholder = "Login or email".localized
        password.placeholder = "Password".localized
        signIn.setTitle("sign in".localized, for: .normal)
        passwordForgot.setTitle("Forgot your password?".localized, for: .normal)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == login {
            password.becomeFirstResponder()
        } else if textField == password {
            self.signInClick(self)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case login:
            return newLength <= 20
        case password:
            return newLength <= 96
        default: print("")
        }
        
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            signInBottomConstraint.constant = notification.name == NSNotification.Name.UIKeyboardWillShow ? keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}
