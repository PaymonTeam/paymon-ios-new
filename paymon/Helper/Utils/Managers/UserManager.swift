//
//  UserManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 20.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

public class UserManager {
    
    static let shared = UserManager()
    
    func authSuccess() {
        User.isAuthenticated = true
        User.saveConfig()
        User.loadConfig()
    }
    
    func signUpNewUser(login : String, password : String, email : String, completionHandler: @escaping (Bool) -> ()) {
        
        let register = RPC.PM_register()
        register.login = login
        register.password = password
        register.email = email
        register.walletKey = "OoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOo";
        
        let _ = NetworkManager.shared.sendPacket(register) { p,e in

            if (p as? RPC.PM_userFull) != nil {
                completionHandler(true)
            } else if e != nil {
                completionHandler(false)
            }
        }
    }

    
    func signIn(login : String, password : String, completionHandler: @escaping (Bool, Bool, Int32) -> ()) {
        
        let auth = RPC.PM_auth()
        auth.id = 0
        auth.login = login
        auth.password = password
        auth.googleCloudToken = ""
        
         NetworkManager.shared.sendPacket(auth) { p, e in

            if let user = p as? RPC.PM_userSelf {
                User.currentUser = user

                if user.confirmed {
                    self.authSuccess()
                } else {
                    completionHandler(true, false, 0)
                }

            } else if let error = e {
                completionHandler(false, false, error.code)
            }
        }
        
    }
    

    func updateProfileInfo(completionHandler: @escaping (Bool) -> ()) {
        
        guard let user = User.currentUser else {return}

        NetworkManager.shared.sendPacket(user) { response, error in
            
            if response is RPC.PM_boolTrue {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    
    
    func sendCodeRecoveryToEmail(loginOrEmail : String, completionHandler: @escaping ((Bool, Int32)) -> ()) {
        let sendCodeToEmail = RPC.PM_restorePasswordRequestCode()
        sendCodeToEmail.loginOrEmail = loginOrEmail
        
        NetworkManager.shared.sendPacket(sendCodeToEmail) { response, error in
            
            if response is RPC.PM_boolTrue {
                completionHandler((true, 0))
            } else {
                if error != nil {
                    completionHandler((false, (error?.code)!))
                } else {
                    completionHandler((false, 0))
                }
            }
        }
    }
    
    func setNewPassword(loginOrEmail : String, code: Int32, password : String, completionHandler: @escaping (Bool) -> ()) {
        
        let setNewPassword = RPC.PM_restorePassword()
        setNewPassword.loginOrEmail = loginOrEmail
        setNewPassword.code = code
        setNewPassword.password = password
        
        NetworkManager.shared.sendPacket(setNewPassword) { response, error in

            if response is RPC.PM_boolTrue {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        
    }
    
    func authByToken() {

        print("auth by token")
            let auth = RPC.PM_authToken()
            
            guard let user = User.currentUser else {
                return
            }
 
            auth.token = user.token
            auth.googleCloudToken = ""

            let _ = NetworkManager.shared.sendPacket(auth) { p, e in
                
                if e != nil || !(p is RPC.PM_userSelf) {
                    print("Error auth by token", e as Any)

                } else {
                    User.currentUser = p as? RPC.PM_userSelf
                    self.authSuccess()
                    MessageManager.shared.loadChats()
                    
                    NotificationManager.instance.postNotificationName(id: NotificationManager.userAuthorized)
                    NetworkManager.shared.sendFutureRequests()
                }
            }
    }
    
    func updateAvatar(info: [UIImagePickerController.InfoKey : Any], completionHandler: @escaping ((Bool, UIImage, Int)) -> ()){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            var resizeImage = UIImage()
            let widthPixel = image.size.width * image.scale
//            let heigthPixel = image.size.height * image.scale
//            print("Image: width \(widthPixel) height: \(heigthPixel)")
            if widthPixel < 256 {
                completionHandler((false, resizeImage, 0))
                return
            }
            if widthPixel > 512 {
                resizeImage = image.resizeWithWidth(width: 512)!
            } else {
                resizeImage = image
            }
//            print("Resize Image: width \(resizeImage.size.width * resizeImage.scale) height: \(resizeImage.size.height * resizeImage.scale)")

            let packet = RPC.PM_setProfilePhoto()
            
            NetworkManager.shared.sendPacket(packet) { packet, error in
                
                if (packet is RPC.PM_boolTrue) {
                    Utils.stageQueue.run {
                        PMFileManager.shared.startUploading(jpegData: resizeImage.jpegData(compressionQuality: 0.85)!, onFinished: {
                            completionHandler((true, resizeImage, -1))
                        }, onError: { code in
                            completionHandler((false, resizeImage, 1))
                        }, onProgress: { p in
                            
                        })
                    }
                } else {
                    completionHandler((false, resizeImage, 2))
                }
            }
        }
    }
    
    func showEmail(isShow : Bool, completionHandler: @escaping (Bool) -> ()){
        
        User.currentUser.isEmailHidden = isShow
        guard let user = User.currentUser else {return}
        
        NetworkManager.shared.sendPacket(user) { response, error in
            
            if response is RPC.PM_boolTrue {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
}


