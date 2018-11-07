//
//  TransactionTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 25.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var lineHeight: NSLayoutConstraint!
    @IBOutlet weak var avatar: CircularImageView!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var time: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineHeight.constant = 0.5
    }
    
    func configure(data: BitcoinTransaction) {
        self.avatar.image = data.avatar
        self.amount.text = data.amount
        self.time.text = data.time
        self.from.text = data.from
        
        switch data.type {
        case .received:
            self.amount.textColor = UIColor.AppColor.Green.recivedTrans
            self.amount.text?.insert("+", at: (self.amount.text?.startIndex)!)
        case .sent:
            self.amount.textColor = UIColor.AppColor.Red.sentTrans
            self.amount.text?.insert("-", at: (self.amount.text?.startIndex)!)
        }
    }
}
