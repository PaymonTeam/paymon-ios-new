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
    @IBOutlet weak var photo: CircularImageView!
    @IBOutlet weak var lastMessagePhoto: CircularImageView!
    @IBOutlet weak var lastMessagePhotoWidth: NSLayoutConstraint!
    @IBOutlet weak var prePhotoWidth: NSLayoutConstraint!
    
    func configure(chat: ChatsData) {
        self.title.text = chat.title
        self.lastMessageText.text = chat.lastMessageText
        self.lastMessageTime.text = Utils.formatDateTime(timestamp: chat.time)
        self.photo.loadPhoto(url: chat.photoUrl)
        
        if chat.lastMessageFromId == User.currentUser.id {
            self.lastMessagePhoto.loadPhoto(url: User.currentUser.photoUrl.url)
        } else {
            lastMessagePhotoWidth.constant = 0
            prePhotoWidth.constant = 0
            self.layoutIfNeeded()
        }
        self.setSelectedColor(color: UIColor.white.withAlphaComponent(0.3))
    }

}

extension UITableViewCell {
    func setSelectedColor(color : UIColor) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = color
        self.selectedBackgroundView = backgroundView
    }
}
