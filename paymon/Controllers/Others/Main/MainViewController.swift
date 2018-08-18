//
//  MainViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 18.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class MainViewController: PaymonViewController {
    var willAuth = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let tabBar = storyboard?.instantiateViewController(withIdentifier: "KeyGuardViewController") as! KeyGuardViewController
//        present(tabBar, animated: true)

    
//        if User.currentUser == nil {
//        performSegue(withIdentifier: VCIdentifier.startViewController, sender: nil)
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
