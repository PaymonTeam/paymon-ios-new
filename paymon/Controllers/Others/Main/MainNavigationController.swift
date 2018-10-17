//
//  MainNavigationController.swift
//  paymon
//
//  Created by Maxim Skorynin on 04/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutOptions()
        
        if isLoggedIn() {
                    
            if User.securityPasscode {
                let passcodeViewController = StoryBoard.passcode.instantiateViewController(withIdentifier: VCIdentifier.passcodeViewController) as! PasscodeViewController
                viewControllers = [passcodeViewController]
            } else {
                let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                viewControllers = [tabsViewController]
            }
        } else {
            self.navigationBar.isHidden = false
            let startViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.startViewController) as! StartViewController
            viewControllers = [startViewController]
        }
        
    }
    
    func isLoggedIn() -> Bool {
        return User.currentUser != nil
    }
    
    func setLayoutOptions() {
        self.navigationBar.setTransparent()
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white.withAlphaComponent(0.7)]
    }
}
