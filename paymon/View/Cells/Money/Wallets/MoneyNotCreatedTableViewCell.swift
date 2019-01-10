//
//  MoneyNotCreatedViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 02.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class MoneyNotCreatedTableViewCell: UITableViewCell {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var add: UIButton!
    
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var addRightConstraint: NSLayoutConstraint!
    var widthScreen : CGFloat!
    
    @IBOutlet weak var restore: UIButton!
    @IBOutlet weak var create: UIButton!
    var cryptoType : CryptoType!
    var heightBackground : CGFloat!
    var viewController : UIViewController!
    
    @IBOutlet weak var backgroundWidth: NSLayoutConstraint!
    
    @IBAction func addClick(_ sender: Any) {
        openAddFunc()
    }
    
    func configure(data: CellMoneyData, vc: UIViewController) {
        self.icon.image = UIImage(named: data.icon)
        self.cryptoType = data.cryptoType
        self.add.backgroundColor = data.cryptoColor
        self.add.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        self.viewController = vc
    }
    
    @IBAction func createClick(_ sender: Any) {
        switch cryptoType {
        case .bitcoin?:
            guard let createNewBtcWalletViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.createNewBtcWalletViewController) as? CreateNewBtcWalletViewController else {return}
            viewController.navigationController?.pushViewController(createNewBtcWalletViewController, animated: true)
        break
            
        case .ethereum?:
            guard let createNewEthWalletViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.createNewEthWalletViewController) as? CreateNewEthWalletViewController else {return}
            viewController.navigationController?.pushViewController(createNewEthWalletViewController, animated: true)
            break
            
        case .paymon?:
            
            break
        default:
            break
        }
    }
    
    @IBAction func restoreClick(_ sender: Any) {
        switch cryptoType {
        case .bitcoin?:
            guard let restoreBtcViewController = StoryBoard.bitcoin.instantiateViewController(withIdentifier: VCIdentifier.restoreBtcViewController) as? RestoreBtcViewController else {return}
            viewController.navigationController?.pushViewController(restoreBtcViewController, animated: true)
            break
            
        case .ethereum?:
            guard let restoreEthViewController = StoryBoard.ethereum.instantiateViewController(withIdentifier: VCIdentifier.restoreEthViewController) as? RestoreEthViewController else {return}
            viewController.navigationController?.pushViewController(restoreEthViewController, animated: true)
            break
            
        case .paymon?:

            break
        default:
            break
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
        add.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 8, right: 12)
        addRightConstraint.constant = 16
        
        buttonsView.layer.cornerRadius = 30
        buttonsView.alpha = 0
        create.setTitle("Create".localized, for: .normal)
        restore.setTitle("Restore".localized, for: .normal)
//        restore.titleLabel?.numberOfLines = 0
//        restore.titleLabel?.minimumScaleFactor = 0.5
//        restore.titleLabel?.adjustsFontSizeToFitWidth = true

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(closeAddFunc(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        
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

        if (swipe.direction == UISwipeGestureRecognizer.Direction.left) {
            
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
