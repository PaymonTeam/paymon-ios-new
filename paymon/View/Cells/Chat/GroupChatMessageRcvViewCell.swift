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
    
    @IBOutlet weak var photo: CircularImageView!
    @IBOutlet weak var name: UILabel!
    
    
    override func draw(_ rect: CGRect) {
        
        let blue = UIColor.AppColor.Blue.chatBlueBubble
        name.textColor = blue
        
        let gray = UIColor.white.withAlphaComponent(0.8)
        
        let bubbleSpace = CGRectMake(self.messageLabel.frame.minX - 8, self.messageLabel.frame.minY - 6,
                                     self.messageLabel.frame.width + timeLabel.frame.width + 20, self.messageLabel.frame.height + 14)
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 13.0)
        
        gray.setFill()
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
