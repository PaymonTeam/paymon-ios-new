//
//  UINavigationBar.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

extension UINavigationBar {
    func setTransparent(){
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }
}

extension UITabBar {
    func setTransparent(){
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }
}
