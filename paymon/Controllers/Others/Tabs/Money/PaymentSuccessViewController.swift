//
//  PaymentSuccess.swift
//  paymon
//
//  Created by Maxim Skorynin on 28/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class PaymentSuccessViewController : PaymonViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var returnToFinance: UIButton!
    
    override func viewDidLoad() {
        self.image.alpha = 0
        self.hint.alpha = 0
        setLayoutOptions()
        animation()
    }
    
    func setLayoutOptions() {
        hint.text = "Payment completed successfully".localized
        returnToFinance.setTitle("Return to finance".localized, for: .normal)
        let widthScreen = UIScreen.main.bounds.width
        self.returnToFinance.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.returnToFinance.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        returnToFinance.layer.cornerRadius = 22

    }
    
    func animation() {
        UIView.animate(withDuration: 0.5, animations: {
                self.image.alpha = 1
                self.hint.alpha = 1
        })
        self.view.layoutIfNeeded()
    }
    
    @IBAction func returnToFinanceClick(_ sender: Any) {
        
    }
}
