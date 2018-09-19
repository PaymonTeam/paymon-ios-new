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
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var addRightConstraint: NSLayoutConstraint!
    var widthScreen : CGFloat!
    
    var cryptoType : CryptoType!

    var heightBackground : CGFloat!
    
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    
    @IBAction func addClick(_ sender: Any) {
        openAddFunc()
    }
    
    @IBAction func createClick(_ sender: Any) {
        switch cryptoType {
        case .bitcoin?:
            // Create Bitcoin wallet code
        break
            
        case .ethereum?:
            // Create Ethereum wallet code
            break
            
        case .paymon?:
            // Create Paymon wallet code
            break
        default:
            print("Default")
        }
    }
    
    @IBAction func restoreClick(_ sender: Any) {
        switch cryptoType {
        case .bitcoin?:
            // Restore Bitcoin wallet code
            break
            
        case .ethereum?:
            // Restore Ethereum wallet code
            break
            
        case .paymon?:
            // Restore Paymon wallet code
            break
        default:
            print("Default")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        self.widthScreen = UIScreen.main.bounds.width
        
        self.background.setGradientLayer(frame: CGRect(x: 0, y: self.background.frame.minY, width: widthScreen, height: self.background.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        self.background.layer.cornerRadius = 30
        self.backgroundWidth.constant = self.widthScreen/2.5
        
        add.layer.cornerRadius = 20
        add.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 8, 12)
        addRightConstraint.constant = 16
        
        buttonsView.layer.cornerRadius = 30
        buttonsView.alpha = 0
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(closeAddFunc(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        
        self.addGestureRecognizer(leftSwipe)
    }
    
    func openAddFunc() {
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.add.alpha = 0
            self.backgroundWidth.constant = self.widthScreen - 32
            self.layoutIfNeeded()
        })
        
        UIView.animate(withDuration: 0.7, animations: {
            self.buttonsView.alpha = 1
        })
    }
    
    @objc func closeAddFunc(swipe:UISwipeGestureRecognizer) {

        if (swipe.direction == UISwipeGestureRecognizerDirection.left) {
            
            UIView.animate(withDuration: 0.1, animations: {
                self.buttonsView.alpha = 0
            })

            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.add.alpha = 1
                self.backgroundWidth.constant = self.widthScreen/2.5
                self.layoutIfNeeded()
            })
        }
    }

}
