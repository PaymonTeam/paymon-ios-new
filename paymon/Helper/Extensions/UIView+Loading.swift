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

    /// To show the loading on view
    func showLoading() {
        guard (self.subviews.last is MBProgressHUD) == false else { return }
        let progressHud = MBProgressHUD.showAdded(to: self, animated: false)
        progressHud.label.text = kLoading
    }
    /// To hide the loading from view
    func hideLoading() {
        MBProgressHUD.hide(for: self, animated: true)
    }
    /// To show the loading on window
    func showLoadingOnWindow() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            let progressHud = MBProgressHUD.showAdded(to: window, animated: false)
            progressHud.label.text = kLoading
        }
    }
    /// To hide the loading from window
    func hideLoadingOnWindow() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            MBProgressHUD.hide(for: window, animated: true)
        }
    }
    
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

