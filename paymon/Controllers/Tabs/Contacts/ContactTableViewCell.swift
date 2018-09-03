//
//  ContactTableViewCell.swift
//  paymon
//
//  Created by SHUBHAM AGARWAL on 01/09/18.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: ObservableImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
