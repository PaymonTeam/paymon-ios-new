//
//  InputCirclePasscodeView.swift
//  paymon
//
//  Created by Maxim Skorynin on 03/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class InputCirclePasscodeView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        self.layer.borderWidth = 1
    }
    
    func fillColor() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.AppColor.Blue.primaryBlue.withAlphaComponent(0.7)
            self.layer.borderColor = UIColor.AppColor.Blue.primaryBlue.withAlphaComponent(0.5).cgColor
            self.layoutIfNeeded()
        })
        
    }
    
    func clearColor() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.clear
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            self.layoutIfNeeded()
        })
    }

}
