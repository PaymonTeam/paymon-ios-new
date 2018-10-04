//
//  PadCollectionViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 03/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class NumPadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 36
    }
    
    func clearBackground() {
        self.label.backgroundColor = UIColor.clear
    }

}
