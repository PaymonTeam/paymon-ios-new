//
//  KeyGuardViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 24.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class KeyGuardViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.width/2
        
    }
}
