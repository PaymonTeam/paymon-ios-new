//
// Created by Vladislav on 24/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit

class ChatsTableViewCell : UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var lastMessageTime: UILabel!
    @IBOutlet weak var photo: ObservableImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
