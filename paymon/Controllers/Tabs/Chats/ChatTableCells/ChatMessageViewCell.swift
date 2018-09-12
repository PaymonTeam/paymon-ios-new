//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit
import Foundation

class ChatMessageViewCell : UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        let blue = UIColor.AppColor.Blue.chatBlueBubble
        let bubbleSpace = CGRectMake(self.messageLabel.frame.minX - 4 - timeLabel.frame.width/4, self.messageLabel.frame.minY - 6,
                self.messageLabel.frame.width + 30 + timeLabel.frame.width, self.messageLabel.frame.height + 14)
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 13.0)

        blue.setFill()
        bubblePath.fill()

    }

    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    override func prepareForReuse() {
        self.setNeedsDisplay()
        super.prepareForReuse()
    }
}
