//
//  ContactWasTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 05.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

public class ContactWasTableViewCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var timeWhenWas: UILabel!
    @IBOutlet weak var avatar: CircularImageView!
    
    func configure(data : ChatsData) {
        self.name.text = data.title
        self.timeWhenWas.text = "last seen ".localized + "\(Utils.formatDateTime(timestamp: data.time))"
        
        self.avatar.loadPhoto(url: data.photoUrl)
    }
}
