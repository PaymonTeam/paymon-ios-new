//
//  AppDelegate.swift
//  paymon
//
//  Created by Maxim Skorynin on 16.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import web3swift
import Geth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificationManagerListener {
    
    var keystore = KeystoreService()
    var window: UIWindow?
    var vc : UIViewController? = UIViewController()
    
    private func authByToken() {
        if User.isAuthenticated {
            return
        }
        if let vc = vc {
            let auth = RPC.PM_authToken()
            print(auth.token)
            auth.token = User.currentUser!.token
            let _ = NetworkManager.instance.sendPacket(auth) { p, e in
//                self.willAuth = false
                
                DispatchQueue.main.async {
                    if e != nil || !(p is RPC.PM_userFull) {
                        User.clearConfig()
                        let startViewController = vc.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.startViewController) as! StartViewController
                        vc.present(startViewController, animated: true)
                    } else {
                        User.isAuthenticated = true
                        User.currentUser = (p as! RPC.PM_userFull)
                        print(User.currentUser ?? "user nil")
                        User.saveConfig()
                        User.loadConfig()
                        
                        let tabsViewController = vc.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                        vc.present(tabsViewController, animated: true)
                        
                        NotificationManager.instance.postNotificationName(id: NotificationManager.userAuthorized)
                        NetworkManager.instance.sendFutureRequests()
                    }
                }
            }
        }
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        User.loadConfig()
        
        //TODO: Need to fix the Error Exception
        NetworkManager.instance.reconnect()
//        print(NetworkManager.instance.isConnected)
        
        if vc == nil {
            vc = window?.rootViewController ?? nil
        }
        
        NotificationManager.instance.addObserver(self, id: NotificationManager.didConnectedToServer)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didDisconnectedFromServer)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didEstablishedSecuredConnection)
        NotificationManager.instance.addObserver(self, id: NotificationManager.authByTokenFailed)
        
        //setup ether
        loadEthenWallet()
        
        return true
    }
    
    func loadEthenWallet() {
        //Choose your namespace and password
        guard let _ = UserDefaults.instance.getEthernAddress() else {
            let passphrase = "qwerty"
            let config = EthAccountConfiguration(namespace: "walletA", password: passphrase)
            
            //Call launch with configuration to create a keystore and account
            //keystoreA: The encrypted private and public key for wallet A
            //accountA : An Ethereum account
            let (keystore, account): (GethKeyStore?,GethAccount?) = EthAccountCoordinator.default.launch(config)
            UserDefaults.instance.setEthernAddress(value: account?.getAddress().getHex())
            KeystoreService().keystore = keystore
            self.keystore.keystore = keystore
            Keychain().passphrase = passphrase
            let jsonKey = try? keystore?.exportKey(account, passphrase: passphrase, newPassphrase: passphrase)
            let keychain = Keychain()
            keychain.jsonKey = jsonKey!
            keychain.passphrase = passphrase
            return
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if vc == nil {
            vc = window?.rootViewController ?? nil
        }
        
        if User.currentUser != nil && !User.isAuthenticated {
//            if willAuth {
                authByToken()
//            } else {
//                willAuth = true
//            }
        }
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func didReceivedNotification(_ id: Int, _ args: [Any]) {
        if id == NotificationManager.didEstablishedSecuredConnection {
            if  User.currentUser != nil && !User.isAuthenticated {
//                if willAuth {
                    authByToken()
//                } else {
//                    willAuth = true
//                }
            }
        } else if id == NotificationManager.didDisconnectedFromServer {
            if !User.isAuthenticated {
//                willAuth = false
            }
        } else if id == NotificationManager.authByTokenFailed {
            User.clearConfig()
            if let vc = vc {
                vc.dismiss(animated: true, completion: nil)
                let startViewController = vc.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.startViewController) as! StartViewController
                vc.present(startViewController, animated: true)
                print("Auth by token failed")
            }
        }
    }
    

}

