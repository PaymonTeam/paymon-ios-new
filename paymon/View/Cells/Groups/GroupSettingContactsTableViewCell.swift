//
//  GroupSettingContactsTableViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 04/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class GroupSettingContactsTableViewCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: CircularImageView!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var cross: UIImageView!
    
    func configure(data : UserData) {
        self.name.text = Utils.formatUserDataName(data)
        self.photo.loadPhoto(url: data.photoUrl!)
    }
}
