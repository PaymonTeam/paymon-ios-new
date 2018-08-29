//
//  TransEmptyTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 25.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class TransEmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var hint: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hint.text = "Transactions list is empty".localized
        
    }

}
