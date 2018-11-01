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
            self.showMainController()
        }
        print("show launch")
        if User.currentUser != nil {
            if !CacheManager.isAddedStorage {
                print("Init DB")
                CacheManager.shared.initDb()
            }
        }
    }
    
    func showMainController() {
        print("ShowMainController")
        guard let window = UIApplication.shared.delegate?.window else {return}
        window!.rootViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.mainNavigationController)
        window!.makeKeyAndVisible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(setMainController)
    }
}
