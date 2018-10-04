//
//  UIView+Loading.swift
//  paymon
//
//  Created by Jogendar Singh on 08/07/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import UIKit
import MBProgressHUD

/// loding constant which will show on loadingView
let kLoading = "Loading"

extension UIView {
    
    func addUIViewBackground(name : String) {
        
        let imageViewBackground = UIImageView(frame: UIScreen.main.bounds)
        imageViewBackground.image = UIImage(named: name)
        
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = [self.center.x - 10, self.center.y]
        animation.toValue = [self.center.x + 10, self.center.y]
        self.layer.add(animation, forKey: "position")
    }
    
    func setGradientLayer(frame : CGRect, topColor : CGColor, bottomColor: CGColor) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = frame
        
        gradientLayer.colors = [topColor, bottomColor]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.clipsToBounds = true
    }
}

