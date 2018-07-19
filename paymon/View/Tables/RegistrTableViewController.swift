//
//  RegistrTableViewController.swift
//  paymon
//
//  Created by maks on 16.11.17.
//  Copyright © 2017 Paymon. All rights reserved.
//

import UIKit

class RegistrTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cellEmail: UITableViewCell!
    @IBOutlet weak var cellRepeatPassword: UITableViewCell!
    @IBOutlet weak var cellPassword: UITableViewCell!
    @IBOutlet weak var cellLogin: UITableViewCell!
    @IBOutlet weak var registrButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    private var observerRegister: NSObjectProtocol!

    var loginValid = false;
    var passwordValid = false;
    var repeatPasswordValid = false;
    var emailValid = false;

    var loginString = ""
    var passwordString = ""
    var emailString = ""

    @objc func endEditing() {
        self.view.endEditing(true)
    }

    func validatePasswordRepeat(_ password:String) -> Bool {
        return password == self.passwordString
    }

    func registr() {

        if !self.loginValid {
            cellLogin.shake()
            return
        }

        if !self.passwordValid {
            cellPassword.shake()
            return
        }

        if !self.repeatPasswordValid {
            cellRepeatPassword.shake()
            return
        }

        if !self.emailValid {
            cellEmail.shake()
            return
        }

        let register = RPC.PM_register()
        register.login = loginString
        register.password = passwordString
        register.email = emailString
        register.walletKey = "OoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOo";
        register.inviteCode = "";

        let _ = NetworkManager.instance.sendPacket(register) { p,e in

            NotificationCenter.default.post(name: .hideIndicatorRegister, object: nil)
            
            if (p as? RPC.PM_userFull) != nil {
                print("User has been registered")


                let alertSuccess = UIAlertController(title: "Registration was successful".localized,
                        message: "Congratulations, you have successfully registered. Account activation sent to your email. Confirm account and log in.".localized,
                        preferredStyle: UIAlertControllerStyle.alert)

                alertSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                    self.dismiss(animated: true)
                }))

                DispatchQueue.main.async {
                    self.present(alertSuccess, animated: true) {
                        () -> Void in
                    }
                }
            } else if e != nil {
                
                NotificationCenter.default.post(name: .registerFalse, object: nil)

                let alertError = UIAlertController(title: "Registration Failed".localized, message: "Such login or email is already in use".localized, preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (UIAlertAction) -> Void in
                }
                alertError.addAction(alertAction)
                DispatchQueue.main.async {
                    self.present(alertError, animated: true) {
                        () -> Void in
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        switch (textField) {
            case loginTextField:
                passwordTextField.becomeFirstResponder()
            case passwordTextField:
                repeatPasswordTextField.becomeFirstResponder()
            case repeatPasswordTextField:
                emailTextField.becomeFirstResponder()
            case emailTextField:
                textField.endEditing(true)
            default: loginTextField.becomeFirstResponder()
        }
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        }

        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        observerRegister = NotificationCenter.default.addObserver(forName: .register, object: nil, queue: nil) {
            notification in

            self.registr()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loginLabel.text = "Login".localized
        passwordLabel.text = "Password".localized
        repeatPasswordLabel.text = "Repeat".localized
        emailLabel.text = "E-mail".localized

        loginTextField.placeholder = "At least 3 symbols".localized
        passwordTextField.placeholder = "At least 8 symbols".localized
        repeatPasswordTextField.placeholder = "Required".localized
        emailTextField.placeholder = "Required".localized

        loginTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
        emailTextField.delegate = self

        registrButton.setTitle("sign up".localized, for: .normal)

        loginTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)

        let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)


    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(observerRegister)
    }

    @objc func textFieldDidChanged(_ textField : UITextField) {
        switch (textField) {
        case loginTextField:
            loginString = loginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            loginValid = Utils.validateLogin(loginString)
            cellLogin.accessoryType = loginValid ? .checkmark : .none
        case passwordTextField:
            passwordString = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            passwordValid = Utils.validatePassword(passwordString)
            cellPassword.accessoryType = passwordValid ? .checkmark : .none
        case repeatPasswordTextField:
            repeatPasswordValid = validatePasswordRepeat(repeatPasswordTextField.text!)
            cellRepeatPassword.accessoryType = repeatPasswordValid ? .checkmark : .none
        case emailTextField:
            emailString = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            emailValid = Utils.validateEmail(emailString)
            cellEmail.accessoryType = emailValid ? .checkmark : .none
        default: print("")
        }

        if loginValid && passwordValid && repeatPasswordValid && emailValid {
            NotificationCenter.default.post(name: .canRegisterTrue, object: nil)
        } else {
            NotificationCenter.default.post(name: .canRegisterFalse, object: nil)
        }
    }

    @IBAction func clickRegistrButton(_ sender: Any) {
        NotificationCenter.default.post(name: .clickRegisterButton, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch (section) {
        case 0: return "Fill out the information".localized
        case 1: return ""
        default: return "Fill out the information".localized
        }
    }
}
