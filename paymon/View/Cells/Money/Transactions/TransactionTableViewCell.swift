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
}
