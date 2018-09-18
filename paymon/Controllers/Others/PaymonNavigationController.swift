//
//  PaymonNavigationController.swift
//  paymon
//
//  Created by Maxim Skorynin on 12.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class PaymonNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setTransparent()
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white.withAlphaComponent(0.7)]

    }
}
