//
//  GroupContactsTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 22/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class GroupContactsTableViewCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: CircularImageView!
    
    func configure(data : UserData) {
        self.name.text = Utils.formatUserDataName(data)
        self.photo.loadPhoto(url: data.photoUrl!)
    }
}
