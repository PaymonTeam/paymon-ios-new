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
        
        let _ = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        
        NetworkManager.instance.auth(login: login, password: password, callback: { p, e in
        
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: viewController.view, animated: true)
            }

            if let user = p as? RPC.PM_userFull {

                if user.confirmed {
                    print("User has logged in")
                    User.currentUser = user
                    print("\(String(describing: User.currentUser?.photoID))")
                    User.isAuthenticated = true
                    User.saveConfig()
                    User.loadConfig()


//                    let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
//                    viewController.present(tabsViewController, animated: true)
                    
                    let profileViewController = StoryBoard.user.instantiateViewController(withIdentifier: VCIdentifier.profileViewController) as! ProfileViewController
                    
                    DispatchQueue.main.async {
                        viewController.present(profileViewController, animated: true)
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
    
    static func updateAvatar(info: [String : Any], avatarView : ObservableImageView, vc : UIViewController){
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage, let currentUser = User.currentUser {
            
            guard let photo = MediaManager.instance.savePhoto(image: image, user: currentUser) else {
                return
            }

            let packet = RPC.PM_setProfilePhoto()
            packet.photo = photo
            let oldPhotoID = currentUser.photoID!
            let photoID = photo.id!
            
            DispatchQueue.main.async {
                avatarView.setPhoto(photo: photo)
            }
            
            ObservableMediaManager.instance.postPhotoUpdateIDNotification(oldPhotoID: oldPhotoID, newPhotoID: photoID)
            
            let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)

            NetworkManager.instance.sendPacket(packet) { packet, error in
                
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: vc.view, animated: true)
                }
                
                if (packet is RPC.PM_boolTrue) {
                    Utils.stageQueue.run {
                        PMFileManager.instance.startUploading(photo: photo, onFinished: {
                            
                            DispatchQueue.main.async {
                                Utils.showSuccesHud(vc: vc)
                            }
                            print("File has uploaded")

                        }, onError: { code in
                            print("file upload failed \(code)")

                        }, onProgress: { p in
                            
                        })
                    }
                } else {
                    let alert = UIAlertController(title: "Update failed".localized, message: "An error occurred during the update".localized, preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        (UIAlertAction) -> Void in
                    }
                    alert.addAction(alertAction)
                    DispatchQueue.main.async {
                        vc.present(alert, animated: true) {
                            () -> Void in
                        }
                    }
                    //TODO переписать в Кастомный алерт
                    PMFileManager.instance.cancelFileUpload(fileID: photoID);
                }
            }
        }
    }
    
    static func updateProfileInfo(name: String, surname : String, email: String, phone: String, city: String, bday: String, country: String, sex : Int, vc : UIViewController) {
        User.currentUser!.city = city
        if (!phone.isEmpty) {
            User.currentUser!.phoneNumber = Int64(phone)
        } else {
            User.currentUser!.phoneNumber = 0
        }
        User.currentUser!.email = email
        User.currentUser!.birthdate = bday
        User.currentUser!.country = country

        User.currentUser!.first_name = name
        User.currentUser!.last_name = surname

        if (sex == 0) {
            User.currentUser!.gender! = 1
        } else if (sex == 1) {
            User.currentUser!.gender! = 2
        }
        
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
                
                let alert = UIAlertController(title: "Update failed".localized, message: "An error occurred during the update".localized, preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (UIAlertAction) -> Void in
                }
                alert.addAction(alertAction)
                DispatchQueue.main.async {
                    vc.present(alert, animated: true) {
                        () -> Void in
                    }
                }
                //TODO: переписать в кастомный алерт
                print("profile update error")
            }
        }
    }
    
}
