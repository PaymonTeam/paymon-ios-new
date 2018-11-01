//
//  ChatsTableCretedGroupCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 05/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class ChatsTableCretedGroupCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    func configure(group : GroupData) {
        self.label.text = "\(Utils.formatUserName(User.currentUser)) "+"created the group chat ".localized+"\"\(group.title!)\""
    }
}
