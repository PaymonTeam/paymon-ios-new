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
        
        let _ = NetworkManager.instance.sendPacket(register) { p,e in

            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
            }
            NotificationCenter.default.post(name: .disableSignUpButtons, object: nil)

            if (p as? RPC.PM_userFull) != nil {
                print("User has been registered")
                let alertSuccess = UIAlertController(title: "Registration was successful".localized, message: "Congratulations, you have successfully registered. Account activation sent to your email. Confirm account and log in.".localized, preferredStyle: UIAlertController.Style.alert)

                alertSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    viewController.navigationController?.popViewController(animated: true)
                }))

                DispatchQueue.main.async {
                    viewController.present(alertSuccess, animated: true) {
                        () -> Void in
                    }
                }
            } else if e != nil {

                let alertError = UIAlertController(title: "Registration Failed".localized, message: "Such login or email is already in use".localized, preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
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
    
    static func signIn(login : String, password : String, vc : UIViewController) {
        
        let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)
        
        print("Send packet")

        
        NetworkManager.instance.auth(login: login, password: password, callback: { p, e in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: vc.view, animated: true)
            }

            if let user = p as? RPC.PM_userFull {

                if user.confirmed {
                    print("User has logged in")
                    User.currentUser = user
                    print("\(String(describing: User.currentUser?.photoUrl))")
                    User.isAuthenticated = true
                    User.saveConfig()
                    User.loadConfig()


                    let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                    
                    DispatchQueue.main.async {
                        vc.present(tabsViewController, animated: true)
                    }
                    
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
                        
                        let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)

                        NetworkManager.instance.sendPacket(resendEmail) { response, error in
                            
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: vc.view, animated: true)
                            }
                            
                            if response is RPC.PM_boolTrue {
                                print("email was resent")
                                
                                _ = SimpleOkAlertController.init(title: "Confirmation email".localized, message: "The letter was sent".localized, vc: vc)

                            } else {
                                
                                _ = SimpleOkAlertController.init(title: "Confirmation email".localized, message: "The email was not sent. Check your internet connection.".localized, vc: vc)

                                print("Error: email was not sent \(String(describing: error))")
                            }

                            User.clearConfig()
                            NetworkManager.instance.reset()
                            NetworkManager.instance.reconnect()
                        }

                    }))
                    DispatchQueue.main.async {
                        vc.present(alert, animated: true, completion: nil)
                    }
                }

            } else if let error = e {

                print("User login failed")

                let msg = (error.code == RPC.ERROR_AUTH ? "Invalid login or password".localized : "An error occurred during authorization".localized)
                
                _ = SimpleOkAlertController.init(title: "Login failed".localized, message: msg, vc: vc)
            }
        })
        
    }
    

    static func updateProfileInfo(name: String, surname : String, vc : UIViewController) {

        User.currentUser!.first_name = name
        User.currentUser!.last_name = surname
        
        let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)

        NetworkManager.instance.sendPacket(User.currentUser!) { response, error in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: vc.view, animated: true)
            }
            
            if (response != nil) {
                User.saveConfig() //TODO: разобраться в работе
                DispatchQueue.main.async {
                    Utils.showSuccesHud(vc: vc)
                    NotificationCenter.default.post(name: .updateView, object: nil)
                    NotificationCenter.default.post(name: .updateString, object: nil)
                }

                print("profile update success")
            } else {
                
                _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: vc)
            
                print("profile update error")
            }
        }
    }
    
    
    
    static func sendCodeRecoveryToEmail(vc : UIViewController, loginOrEmail : String) {
        let sendCodeToEmail = RPC.PM_restorePasswordRequestCode()
        sendCodeToEmail.loginOrEmail = loginOrEmail
        let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)
        
        NetworkManager.instance.sendPacket(sendCodeToEmail) { response, error in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: vc.view, animated: true)
            }
            
            if response is RPC.PM_boolTrue {
                print("code sent")
                 let forgotPasswordCodeViewController = StoryBoard.forgotPassword.instantiateViewController(withIdentifier: VCIdentifier.forgotPasswordCodeViewController) as! ForgotPasswordCodeViewController
                
                forgotPasswordCodeViewController.emailValue = loginOrEmail

                    DispatchQueue.main.async {
                        vc.navigationController?.pushViewController(forgotPasswordCodeViewController, animated: true)
                    }
                
            } else {
                //TODO: Если вернуться назад, приходит false но без ошибки
                if let err = error?.code! {
                    if err == 27 {
                        
                        _ = SimpleOkAlertController.init(title: "Recovery password".localized, message: "This login or e-mail address is not exist".localized, vc: vc)
                    } else {

                        _ = SimpleOkAlertController.init(title: "Recovery password".localized, message: "An error occurred while sending the recovery code".localized, vc: vc)
                    }
                }
            }
        }
    }
    
    static func setNewPassword(loginOrEmail : String, code: Int32, password : String, vc : UIViewController) {
        let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)
        
        let setNewPassword = RPC.PM_restorePassword()
        setNewPassword.loginOrEmail = loginOrEmail
        setNewPassword.code = code
        setNewPassword.password = password
        
        NetworkManager.instance.sendPacket(setNewPassword) { response, error in
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: vc.view, animated: true)
            }
            
            if response is RPC.PM_boolTrue {
                print("code is true")
                    
                let alertSuccess = UIAlertController(title: "New password".localized, message: "Password changed successfully".localized, preferredStyle: UIAlertController.Style.alert)
                
                alertSuccess.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    vc.navigationController?.popToViewController((vc.navigationController?.viewControllers[1])!, animated: true)
                }))
                
                DispatchQueue.main.async {
                    vc.present(alertSuccess, animated: true) {
                        () -> Void in
                    }
                }
            } else {
                print("code is false \(String(describing: error?.code))")
                DispatchQueue.main.async {
                    vc.navigationController?.popViewController(animated: true)
                    
                    _ = SimpleOkAlertController.init(title: "New password".localized, message: "You entered an invalid recovery code".localized, vc: vc)
                }
            }
        }
        
    }
    
    static func authByToken() {

            let auth = RPC.PM_authToken()
            
            guard let user = User.currentUser else {
                return
            }
            
            auth.token = user.token

            let _ = NetworkManager.instance.sendPacket(auth) { p, e in
                
                if e != nil || !(p is RPC.PM_userFull) {
                    print("Error auth by token", e as Any)

                } else {
                    User.isAuthenticated = true
                    User.currentUser = (p as! RPC.PM_userFull)
                    print(User.currentUser.photoUrl.url)
                    
                    User.saveConfig()
                    User.loadConfig()

                    NotificationManager.instance.postNotificationName(id: NotificationManager.userAuthorized)
                    NetworkManager.instance.sendFutureRequests()
                }
            }
    }
    
    static func updateAvatar(info: [UIImagePickerController.InfoKey : Any], avatarView : CircularImageView, vc : UIViewController){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            var resizeImage = UIImage()
            
            let widthPixel = image.size.width * image.scale
//            let heigthPixel = image.size.height * image.scale
            
//            print("Image: width \(widthPixel) height: \(heigthPixel)")
            if widthPixel < 256 {
                _ = SimpleOkAlertController.init(title: "Upload photo failed".localized, message: "The minimum width of the photo can be 256 points".localized, vc: vc)
                return
            }
            if widthPixel > 512 {
                resizeImage = image.resizeWithWidth(width: 512)!
            } else {
                resizeImage = image
            }
//            print("Resize Image: width \(resizeImage.size.width * resizeImage.scale) height: \(resizeImage.size.height * resizeImage.scale)")

            let packet = RPC.PM_setProfilePhoto()
            
            let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)
            
            NetworkManager.instance.sendPacket(packet) { packet, error in
                
                if (packet is RPC.PM_boolTrue) {
                    Utils.stageQueue.run {
                        PMFileManager.instance.startUploading(jpegData: resizeImage.jpegData(compressionQuality: 0.85)!, onFinished: {
                            
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: vc.view, animated: true)
                                Utils.showSuccesHud(vc: vc)
                                
                                avatarView.image = resizeImage

                            }
                            print("File has uploaded")
                            
                        }, onError: { code in
                            print("file upload failed \(code)")
                            
                            DispatchQueue.main.async {
                                _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: vc)
                            }
                            
                        }, onProgress: { p in
                            
                        })
                    }
                } else {
                    
                    _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: vc)
                    
                    //TODO переписать в Кастомный алерт
                    PMFileManager.instance.cancelFileUpload(fileID: Int64(User.currentUser.id));
                }
            }
        }
    }
}
