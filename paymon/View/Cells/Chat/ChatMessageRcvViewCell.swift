//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

class ChatMessageRcvViewCell : UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubble.layer.cornerRadius = 18
    }

    func configure(message: ChatMessageData) {
        self.messageLabel.text = message.text
        self.timeLabel.text = Utils.formatMessageDateTime(timestamp: message.date)
    }
    
}
