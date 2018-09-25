//
//  CircularImageView.swift
//  paymon
//
//  Created by Maxim Skorynin on 19.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    func loadPhoto(url: String) {
        
        if !url.isEmpty {

            self.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "NonPhoto"), options: [.refreshCached], completed: nil)

        }
        
    }
}

public class CircularImageView: UIImageView {
    
    var fromId : Int32!

    override public func awakeFromNib() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/2
    }
    
}
