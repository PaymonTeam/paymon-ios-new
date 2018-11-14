//
//  SignInViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 21.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import MBProgressHUD

class SignInViewController: PaymonViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var signInItem: UIBarButtonItem!

    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordForgot: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signInBottomConstraint: NSLayoutConstraint!
    private var setMainController: NSObjectProtocol!

    
    @IBOutlet weak var stackTestFields: UIView!
    @IBAction func passwordForgotClick(_ sender: Any) {
        let forgotPasswordEmailViewController = StoryBoard.forgotPassword.instantiateViewController(withIdentifier: VCIdentifier.forgotPasswordEmailViewController) as! ForgotPasswordEmailViewController
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(forgotPasswordEmailViewController, animated: true)
        }
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
            UserManager.shared.signIn(login: (login.text?.trimmingCharacters(in: .whitespacesAndNewlines))!, password: (password.text?.trimmingCharacters(in: .whitespacesAndNewlines))!, vc: self)
        }
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        setMainController = NotificationCenter.default.addObserver(forName: .setMainController, object: nil, queue: nil) {
            notification in
            
            DispatchQueue.main.async {
                let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                self.present(tabsViewController, animated: true)
            }
            
        }
        setLayoutOptions()

    }
    
    func setLayoutOptions() {
        self.view.addUIViewBackground(name: "MainBackground")
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        login.delegate = self
        password.delegate = self
        
        login.placeholder = "Login or email".localized
        password.placeholder = "Password".localized
        signIn.setTitle("sign in".localized, for: .normal)
        passwordForgot.setTitle("Forgot your password?".localized, for: .normal)
        
        self.title = "Sign in".localized
        
        self.stackTestFields.layer.masksToBounds = true
        self.stackTestFields.layer.cornerRadius = 30
        self.signIn.layer.cornerRadius = self.signIn.frame.height/2
        
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
            return newLength <= 128
        case password:
            return newLength <= 96
        default: break
        }
        
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            
            signInBottomConstraint.constant = notification.name == UIResponder.keyboardWillShowNotification ? keyboardFrame!.height + 8 : 8
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0,
                               delay: 0,
                               options: UIView.AnimationOptions.curveEaseOut,
                               animations: {
                                self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(setMainController)
    }
}
