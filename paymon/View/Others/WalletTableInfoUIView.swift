//
//  WalletTableInfoUIView.swift
//  paymon
//
//  Created by Maxim Skorynin on 24.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class WalletTableInfoUIView: UIView {
    
    override func draw(_ rect: CGRect) {
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        let width: CGFloat = UIScreen.main.bounds.width
        
        self.setGradientLayer(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height), topColor: UIColor.AppColor.Black.walletTableInfoLight.cgColor, bottomColor: UIColor.AppColor.Black.walletTableInfoDark.cgColor)
        
        self.layer.cornerRadius = 30
        
    }
    
}

