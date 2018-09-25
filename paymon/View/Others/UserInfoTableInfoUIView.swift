//
//  UserInfoTableInfoUIView.swift
//  paymon
//
//  Created by Maxim Skorynin on 24.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class UserInfoTableInfoUIView: UIView {
    
    override func draw(_ rect: CGRect) {
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        
        self.layer.cornerRadius = self.frame.height/2
        
    }
    
}
