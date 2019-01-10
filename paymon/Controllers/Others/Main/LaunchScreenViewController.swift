//
//  LaunchScreenViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 25/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class LaunchScreenViewController : UIViewController {
    
    private var setMainController: NSObjectProtocol!
    
    override func viewDidLoad() {
        setMainController = NotificationCenter.default.addObserver(forName: .setMainController, object: nil, queue: nil) {
            notification in
            EthereumManager.shared.initWallet()
            self.showMainController()
        }
    }
    
    func showMainController() {
        print("ShowMainController")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Cant change state main controller")
            return
        }
        print("change state main controller")

        DispatchQueue.main.async {
            appDelegate.window?.rootViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.mainNavigationController)
            appDelegate.window?.makeKeyAndVisible()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(setMainController)
    }
}
