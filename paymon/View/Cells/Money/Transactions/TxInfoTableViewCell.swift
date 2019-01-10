//
//  TxInfoTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 25/12/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class TxInfoTableViewCell : UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineHeight.constant = 0.5
    }
    
    func configure(data : EthTxInfoData, row : Int) {
        self.title.text = data.title

        switch row {
        case 2:
            self.info.text = Utils.formatTxInfoTime(timestamp: Int32(data.info)!)
        case 5:
            let decimalValue = Decimal(data.info) / Decimal(Money.fromWei)
            self.info.text = String(format: "%.2f ETH", decimalValue.double)
        case 8:
            let decimalValue = Decimal(data.info) / Decimal(Money.fromWei)
            self.info.text = "\(decimalValue) ETH"
            
        default:
            self.info.text = data.info
        }
    }
}
