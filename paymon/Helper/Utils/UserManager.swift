//
//  UserManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 20.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

public class UserManager {
    
    static func signUpNewUser(login : String, password : String, email : String, viewController : UIViewController) {
        
        let _ = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        
        let register = RPC.PM_register()
        register.login = login
        register.password = password
        register.email = email
        register.walletKey = "OoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOo";
//        register.inviteCode = "";
        
        let _ = NetworkManager.instance.sendPacket(register) { p,e in

            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
            }
            NotificationCenter.default.post(name: .disableSignUpButtons, object: nil)

            if (p as? RPC.PM_userFull) != nil {
                print("User has been registered")
                let alertSuccess = UIAlertController(title: "Registration was successful".localized, message: "Congratulations, you have successfully registered. Account activation sent to your email. Confirm account and log in.".localized, preferredStyle: UIAlertControllerStyle.alert)

                alertSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                    viewController.dismiss(animated: true)
                }))

                DispatchQueue.main.async {
                    viewController.present(alertSuccess, animated: true) {
                        () -> Void in
                    }
                }
            } else if e != nil {

                let alertError = UIAlertController(title: "Registration Failed".localized, message: "Such login or email is already in use".localized, preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                    NotificationCenter.default.post(name: .enableSignUpButtons, object: nil)
                })

                alertError.addAction(alertAction)
                DispatchQueue.main.async {
                    viewController.present(alertError, animated: true) {
                        () -> Void in
                    }
                }
            }
        }
    }
    
    static func signIn(login : String, password : String, viewController : UIViewController) {
        
        _ = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        
        NetworkManager.instance.auth(login: login, password: password, callback: { p, e in
        
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
            }

            if let user = p as? RPC.PM_userFull {

                if user.confirmed {
                    print("User has logged in")
                    User.currentUser = user
                    User.isAuthenticated = true
                    User.saveConfig()
                    User.loadConfig()

                    print("true login")

                    let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                    viewController.present(tabsViewController, animated: true)
                } else {

                    let alert = UIAlertController(title: "Confirmation email".localized,
                          message: String(format: NSLocalizedString("You did not verify your account by email \n %@ \n\n Send mail again?".localized, comment: ""), user.email),
                          preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
                        User.clearConfig()
                        NetworkManager.instance.reset()
                        NetworkManager.instance.reconnect()
                    }))

                    alert.addAction(UIAlertAction(title: "Send".localized, style: .default, handler: { (action) in

                        let resendEmail = RPC.PM_resendEmail()

                        NetworkManager.instance.sendPacket(resendEmail) { response, error in
                            if response is RPC.PM_boolTrue {
                                print("Я переслал письмо")

                                let alert = UIAlertController(title: "Confirmation email".localized,
                                                              message: "The letter was sent".localized,
                                                              preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in

                                }))
                                DispatchQueue.main.async {
                                    viewController.present(alert, animated: true)
                                }
                            } else {
                                let alert = UIAlertController(title: "Confirmation email".localized, message: "The email was not sent. Check your internet connection.".localized, preferredStyle: .alert)

                                alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action) in

                                }))
                                DispatchQueue.main.async {
                                    viewController.present(alert, animated: true)
                                }

                                print(error ?? "Я не смог отправить письмо")
                            }

                            User.clearConfig()
                            NetworkManager.instance.reset()
                            NetworkManager.instance.reconnect()
                        }

                    }))
                    DispatchQueue.main.async {
                        viewController.present(alert, animated: true, completion: nil)
                    }
                }

            } else if let error = e {

                print("User login failed")

                let msg = (error.code == RPC.ERROR_AUTH ? "Invalid login or password".localized : "Unknown error")
                let alert = UIAlertController(title: "Login Failed".localized, message: msg, preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (UIAlertAction) -> Void in
                }
                alert.addAction(alertAction)
                DispatchQueue.main.async {
                    viewController.present(alert, animated: true) {
                        () -> Void in
                    }
                }
            }
        })
        
    }
    
}
