//
//  BitcoinTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 01.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoneyCreatedTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var fiatAmount: UILabel!
    @IBOutlet weak var cryptoAmount: UILabel!
    @IBOutlet weak var fiatHint: UILabel!
    @IBOutlet weak var cryptoHint: UILabel!
    
    var cryptoType : CryptoType!
    
    @IBOutlet weak var background: UIView!
    var heightBackground : CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        let width: CGFloat = UIScreen.main.bounds.width
        
        self.background.setGradientLayer(frame: CGRect(x: 0, y: self.background.frame.minY, width: width, height: self.background.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.background.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(data: CellCreatedMoneyData) {
        self.icon.image = UIImage(named: data.icon)
        self.cryptoAmount.text = data.currancyAmount.description
        self.fiatAmount.text = data.fiatAmount.description
        self.cryptoHint.text = data.cryptoHint
        self.fiatHint.text = data.fiatHint
        self.cryptoType = data.cryptoType
        
        self.cryptoHint.textColor = data.cryptoColor
        self.cryptoAmount.textColor = data.cryptoColor
        self.fiatHint.textColor = data.fiatColor
        self.fiatAmount.textColor = data.fiatColor
    }
}

