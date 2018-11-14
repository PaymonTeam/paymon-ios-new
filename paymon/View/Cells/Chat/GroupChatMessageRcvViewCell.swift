//
//  GroupChatMessageRcvViewCell.swift
//  paymon
//
//  Created by Maxim Skorynin on 10.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class GroupChatMessageRcvViewCell : UITableViewCell{
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var bubble: UIView!
    @IBOutlet weak var photo: CircularImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        name.textColor = UIColor.AppColor.Blue.chatBlueBubble
        bubble.layer.cornerRadius = 18
        
    }
    
    func configure(message: ChatMessageData) {
        self.messageLabel.text = message.text
        self.timeLabel.text = Utils.formatMessageDateTime(timestamp: message.date)
        
        if let user = UserDataManager.shared.getUserById(id: message.fromId) {
            self.name.text = Utils.formatUserDataName(user)
            self.photo.loadPhoto(url: (user.photoUrl!))
            self.photo.fromId = message.fromId
        }
    }
}
