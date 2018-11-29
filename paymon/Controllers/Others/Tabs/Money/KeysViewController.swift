//
//  KeysViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 30.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class KeysViewController: UIViewController {

    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var key: UILabel!
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var backItem: UIView!
    @IBOutlet weak var cancel: UIButton!
    var keyValue : String!
    var currency : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key.text = keyValue
        share.setTitle("Share".localized, for: .normal)
        cancel.setTitle("Cancel".localized, for: .normal)
        
        setLayoutOptions()
        
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareClick(_ sender: Any) {
        let shareActivity = UIActivityViewController(activityItems: [keyValue], applicationActivities: [])
        
        shareActivity.popoverPresentationController?.sourceView = self.view
        shareActivity.popoverPresentationController?.sourceRect = self.view.bounds
        
        present(shareActivity, animated: true)
    }
    
    func setLayoutOptions() {
        
        backItem.layer.cornerRadius = 4
        let widthScreen = UIScreen.main.bounds.width
        
        switch currency {
        case Money.btc:
            infoView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: infoView.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
            
            share.backgroundColor = UIColor.AppColor.Orange.bitcoinBalanceLight
        case Money.eth:
            infoView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: infoView.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
            
            share.backgroundColor = UIColor.AppColor.Blue.ethereumBalanceLight
        default:
            break
        }
        
        infoView.layer.cornerRadius = 30
        share.layer.cornerRadius = share.frame.height/2
        DispatchQueue.main.async {
            let qr = try? QRService().createQR(fromString: self.keyValue, size: CGSize(width: self.qrCode.frame.width, height: self.qrCode.frame.height))
            self.qrCode.image = qr
        }
        
    }
}
