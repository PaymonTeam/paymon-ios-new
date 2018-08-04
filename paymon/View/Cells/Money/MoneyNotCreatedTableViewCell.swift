//
//  MoneyNotCreatedViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 02.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class MoneyNotCreatedTableViewCell: UITableViewCell {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var add: UIButton!
    
    var cryptoType : CryptoType!

    var heightBackground : CGFloat!
    
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    @IBAction func addClick(_ sender: Any) {
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        let width: CGFloat = UIScreen.main.bounds.width
        
        self.background.setGradientLayer(frame: CGRect(x: 0, y: self.background.frame.minY, width: width, height: self.background.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.background.layer.cornerRadius = 30
        self.backgroundWidth.constant = width/2.5
        
        add.layer.cornerRadius = 20
        add.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 8, 12)
    }

}
