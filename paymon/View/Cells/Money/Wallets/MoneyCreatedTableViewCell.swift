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
    @IBOutlet weak var download: UILabel!
    
    var cryptoType : CryptoType!
    
    @IBOutlet weak var background: UIView!
    var heightBackground : CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        download.text = "Download...".localized

        let width: CGFloat = UIScreen.main.bounds.width
        
        self.background.setGradientLayer(frame: CGRect(x: 0, y: self.background.frame.minY, width: width, height: self.background.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.background.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(data: CellCreatedMoneyData) {
        self.icon.image = UIImage(named: data.icon)
        self.cryptoAmount.text = String(format: "%.\(User.symbCount)f", data.currancyAmount)
        self.fiatAmount.text = String(format: "%.2f", data.fiatAmount)
        self.cryptoHint.text = data.cryptoHint
        self.fiatHint.text = data.fiatHint
        self.cryptoType = data.cryptoType
//        showBalance(cryptoType: data.cryptoType)
        self.cryptoHint.textColor = data.cryptoColor
        self.cryptoAmount.textColor = data.cryptoColor
        self.fiatHint.textColor = data.fiatColor
        self.fiatAmount.textColor = data.fiatColor
    }
    
    func showBalance(cryptoType : CryptoType) {
//        if cryptoType == CryptoType.ethereum && CryptoManager.shared.ethInfoIsLoaded {
//            print("show balance eth")
////            DispatchQueue.main.async {
//                self.download.isHidden = true
//                self.cryptoAmount.isHidden = false
//                self.fiatAmount.isHidden = false
//                self.cryptoHint.isHidden = false
//                self.fiatHint.isHidden = false
////            }
//        } else {
//            self.download.isHidden = false
//            self.cryptoAmount.isHidden = true
//            self.fiatAmount.isHidden = true
//            self.cryptoHint.isHidden = true
//            self.fiatHint.isHidden = true
//        }
        
//        if cryptoType == CryptoType.bitcoin && CryptoManager.shared.btcInfoIsLoaded {
//            self.download.isHidden = true
//            self.cryptoAmount.isHidden = false
//            self.fiatAmount.isHidden = false
//            self.cryptoHint.isHidden = false
//            self.fiatHint.isHidden = false
//        } else {
//            self.download.isHidden = false
//            self.cryptoAmount.isHidden = true
//            self.fiatAmount.isHidden = true
//            self.cryptoHint.isHidden = true
//            self.fiatHint.isHidden = true
//        }
    }
}

