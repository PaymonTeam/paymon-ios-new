//
//  ExchangeRatesTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 03.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class ExchangeRatesTableViewCell: UITableViewCell {
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var fiatLabel: UILabel!
    @IBOutlet weak var amount: UIButton!
    
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setLayoutOptions()
        
    }
    
    func setLayoutOptions(){
        
        lineHeight.constant = 0.5
        amount.sizeToFit()
        
    }

}
