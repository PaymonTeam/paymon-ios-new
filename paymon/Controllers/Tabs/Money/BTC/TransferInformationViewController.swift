//
//  TransferInformationViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 30.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class TransferInformationViewController: UIViewController {
    
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalAmountHint: UILabel!
    @IBOutlet weak var networkFeeAmount: UILabel!
    @IBOutlet weak var networkFeeHint: UILabel!
    @IBOutlet weak var toWallet: UILabel!
    @IBOutlet weak var toHint: UILabel!
    @IBOutlet weak var yourWallet: UILabel!
    @IBOutlet weak var yourWalletBalance: UILabel!
    @IBOutlet weak var fromHint: UILabel!
    
    @IBOutlet weak var stackView: UIView!
    
    var balanceValue : Double!
    var toAddress : String!
    var networkFeeValue : Double!
    var totalAmountValue : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        
    }
    
    func setLayoutOptions() {
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.stackView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: self.stackView.frame.width, height: self.stackView.frame.height), topColor: UIColor.AppColor.Black.walletTableInfoLight.cgColor, bottomColor: UIColor.AppColor.Black.walletTableInfoDark.cgColor)
        
        stackView.layer.cornerRadius = 30
        
        self.send.setGradientLayer(frame: CGRect(x: 0, y: 0, width: send.frame.width, height: self.send.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.send.layer.cornerRadius = self.send.frame.width/2
        
        toHint.text = "To".localized
        fromHint.text = "From".localized
        yourWallet.text = "Your wallet".localized
        networkFeeHint.text = "Network fee".localized
        totalAmountHint.text = "Total amount".localized
        self.title = "Transfer info".localized
    }
}
