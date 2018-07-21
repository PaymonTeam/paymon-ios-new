//
//  SignInViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 21.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import MBProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var signInItem: UIBarButtonItem!
    @IBOutlet weak var arrowBack: UIBarButtonItem!
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordForgot: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signInBottomConstraint: NSLayoutConstraint!
    
    
    @IBAction func passwordForgotClick(_ sender: Any) {
        //TODO: Create new view
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
            UserManager.signIn(login: "", password: "", viewController: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.topItem?.title = "Sign in".localized
        
        login.placeholder = "Login or email".localized
        password.placeholder = "Password".localized
        signIn.setTitle("sign in".localized, for: .normal)
        passwordForgot.setTitle("Forgot your password?".localized, for: .normal)

    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            signInBottomConstraint.constant = isKeyboardShowing ? keyboardFrame!.height : 0
            
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
