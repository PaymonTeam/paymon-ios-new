//
//  MainViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 18.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class MainViewController: UIViewController {
    var willAuth = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if User.currentUser == nil {
//            let startViewController = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.startViewController) as! StartViewController
//            present(startViewController, animated: true)
//        } else if User.securitySwitchPasswordProtected && !User.securityPasswordProtectedString.isEmpty {
//            let keyGuard = storyboard?.instantiateViewController(withIdentifier: "KeyGuardViewController") as! KeyGuardViewController
//            present(keyGuard, animated: true)
//        }
//        else {
    
//            let tabBar = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
//            present(tabBar, animated: true)
//        }
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
