//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit
import UserNotifications

class ChatViewController: PaymonViewController, NotificationManagerListener {
    
    @IBOutlet weak var messageTextView: UITextView!

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sendButtonImage: UIImageView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contraintViewBottom: NSLayoutConstraint!

    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatSubtitle: UILabel!
    @IBOutlet weak var customTitleView: UIView!
    var messages: [Int64] = [] //RPC.Message?
    var chatID: Int32!
    var isGroup: Bool!
    var users = SharedArray<RPC.UserObject>()
    
    private var updateMessagesId : NSObjectProtocol!

    
    @IBAction func onSendClicked() {
        
        guard let text = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty, text != "To write a message".localized else {return}
        
        messageTextView.text = ""
        textViewDidChange(messageTextView)

        MessageManager.instance.sendMessage(text: text, isGroup : isGroup, chatId : chatID, messages: self.messages)
        
    }
    
    func setLayoutOptions() {
        messageTextView.layer.cornerRadius = messageTextView.frame.height/2
        messageTextView.text = "To write a message".localized
        messageTextView.textColor = UIColor.white.withAlphaComponent(0.4)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        textViewDidChange(messageTextView)
        
        self.chatTitle.text = value(forKey: "title") as? String
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        sendButton.layer.cornerRadius = sendButton.frame.height/2
        customTitleView.sizeToFit()
        if self.backButton != nil {
            self.backButton.title = "Back".localized
        }
    }
    
    @IBAction func titleClick(_ sender: Any) {
        
        if isGroup {
            guard let groupSettingVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.groupSettingViewController) as? GroupSettingViewController else {return}
            groupSettingVC.chatID = chatID
            
            navigationController?.pushViewController(groupSettingVC, animated: true)
        } else {
            guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
            friendProfileVC.id = chatID
            friendProfileVC.fromChat = true
            
            navigationController?.pushViewController(friendProfileVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationManager.instance.addObserver(self, id: NotificationManager.chatAddMessages)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didReceivedNewMessages)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        updateMessagesId = NotificationCenter.default.addObserver(forName: .updateMessagesId, object: nil, queue: nil ){ notification in
            
            if let messagesId = notification.object as? [Int64] {
                self.messages = messagesId
                
                DispatchQueue.main.async {
                    let index = IndexPath(row: self.messages.count > 0 ? self.messages.count - 1 : 0, section: 0)
                    self.tableView.insertRows(at: [index], with: .bottom)
                    self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
                }
            }
        }
        
        if isGroup {
            users = MessageManager.instance.groupsUsers.value(forKey: chatID)!
        }
        
        setLayoutOptions()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        messageTextView.delegate = self
        
        let getChatMessages = RPC.PM_getChatMessages()
        getChatMessages.count = 20
        if isGroup {
            let peerGroup = RPC.PM_peerGroup()
            peerGroup.group_id = chatID;
            getChatMessages.chatID = peerGroup
            
            let group:RPC.Group! = MessageManager.instance.groups[chatID]!

            var text = "Participants: ".localized
            text.append("\(group.users.count)")
            
            chatSubtitle.text = text

//            groupIconImageView.setPhoto(ownerID: group.id, photoID: group.photo.id)
        } else {
            let peerUser = RPC.PM_peerUser()
            peerUser.user_id = chatID;
            getChatMessages.chatID = peerUser
            chatSubtitle.text = "Online"

//            groupIconImageView.isHidden = true
        }
        getChatMessages.offset = 0
        MessageManager.instance.loadMessages(chatID: chatID, count: 20, offset: 0, isGroup: isGroup)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            contraintViewBottom.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: {
                (completed) in
                
                DispatchQueue.main.async {
                    
                    if isKeyboardShowing {
                        if self.messages.count >= 1 {
                            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                        }
                    }

                }
                
            })
        }
    }
    
    func didReceivedNotification(_ id: Int, _ args: [Any]) {
        if id == NotificationManager.chatAddMessages {
            
            if args.count == 2 {
                if args[1] is Bool {
                    if let messagesToAdd = args[0] as? [Int64] {
                        
                        DispatchQueue.global().sync {
                            messages.append(contentsOf: messagesToAdd)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        if self.messages.count > 0 {
                            let index = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: index, at: .bottom, animated: false)

                        }
                    }
                }
            }
        } else if id == NotificationManager.didReceivedNewMessages {
            
            if args.count == 1 {
                if let messagesToAdd = args[0] as? [RPC.Message] {
                    messagesToAdd.forEach({ msg in
                        DispatchQueue.global().sync {
                            self.messages.append(msg.id)
                        }
                    })
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    if self.messages.count > 0 {
                        let index = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: index, at: .bottom, animated: true)

                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.chatAddMessages)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.didReceivedNewMessages)
        NotificationCenter.default.removeObserver(updateMessagesId)
        
    }
    
    @objc func clickPhoto(_ sender : UITapGestureRecognizer) {
        guard let photo = sender.view as? ObservableImageView else {return}
        
        guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
        friendProfileVC.id = photo.getOwnerId()
        friendProfileVC.fromChat = false
        
        navigationController?.pushViewController(friendProfileVC, animated: true)
        
    }
    
}

extension ChatViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let mid = messages[row]
        if let message = MessageManager.instance.messages[mid] {
            if message.from_id == User.currentUser!.id {
                if message.itemType == nil || message.itemType == .NONE {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageViewCell") as! ChatMessageViewCell
                    cell.messageLabel.text = message.text
                    cell.timeLabel.text = Utils.formatChatDateTime(timestamp: Int64(message.date), format24h: false)
                    cell.messageLabel.sizeToFit()
                    return cell
                }
//                else {
//                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageItemViewCell") as! ChatMessageItemViewCell
//                    cell.stickerImage.setSticker(itemType: message.itemType, itemID: message.itemID)
//                    return cell
//                }
            } else {
                if isGroup {
                    print("isGroup")
                    if message.itemType == nil || message.itemType == .NONE {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatMessageRcvViewCell") as! GroupChatMessageRcvViewCell
                        cell.messageLabel.text = message.text
                        cell.messageLabel.sizeToFit()
                        cell.timeLabel.text = Utils.formatChatDateTime(timestamp: Int64(message.date), format24h: false)
                        cell.photo.setPhoto(ownerID: message.from_id, photoID: MediaManager.instance.userProfilePhotoIDs[message.from_id]!)
                        
                        let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.clickPhoto(_:)))
                        cell.photo.isUserInteractionEnabled = true
                        cell.photo.addGestureRecognizer(tapPhoto)
                        
                        let user = MessageManager.instance.users[message.from_id]
                        cell.name.text = Utils.formatUserName(user!)
                        return cell
                    }
//                    else {
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageItemRcvViewCell") as! ChatMessageItemRcvViewCell
//                        cell.stickerImage.setSticker(itemType: message.itemType, itemID: message.itemID)
//                        return cell
//                    }
                } else {
                    if message.itemType == nil || message.itemType == .NONE {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageRcvViewCell") as! ChatMessageRcvViewCell
                        cell.messageLabel.text = message.text
                        cell.timeLabel.text = Utils.formatChatDateTime(timestamp: Int64(message.date), format24h: false)
                        cell.messageLabel.sizeToFit()
                        return cell
                    }
//                    else {
//                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageItemRcvViewCell") as! ChatMessageItemRcvViewCell
//                        cell.stickerImage.setSticker(itemType: message.itemType, itemID: message.itemID)
//                        return cell
//                    }
                }
                
            }
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTextView.endEditing(true)
    }
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
        if !textView.text.isEmpty && textView.text != "To write a message".localized {
            UIView.animate(withDuration: 0.2, animations: {
                self.sendButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                self.sendButtonImage.image = #imageLiteral(resourceName: "SendColor")
                self.sendButtonImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.sendButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                self.sendButtonImage.image = #imageLiteral(resourceName: "SendGray")
                self.sendButtonImage.transform = CGAffineTransform(rotationAngle: 0)

                self.view.layoutIfNeeded()

            })
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.textColor == UIColor.white.withAlphaComponent(0.4) {
            textView.text = ""
            textView.textColor = UIColor.white.withAlphaComponent(0.8)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "To write a message".localized
            textView.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }
}
