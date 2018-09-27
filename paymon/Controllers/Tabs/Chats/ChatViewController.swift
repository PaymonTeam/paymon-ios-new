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
    var afterScroll = false
    var startView = true
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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

        setLayoutOptions()
        
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.delegate = self

        if isGroup {
            users = MessageManager.instance.groupsUsers.value(forKey: chatID)!

            let group:RPC.Group! = MessageManager.instance.groups[chatID]!

            var text = "Participants: ".localized
            text.append("\(group.users.count)")
            
            chatSubtitle.text = text

        } else {
            chatSubtitle.text = "Online"
        }
        
        MessageManager.instance.loadMessages(chatID: chatID, count: 40, offset: 0, isGroup: isGroup)
        
    }
    
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            contraintViewBottom.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
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
                    if var messagesToAdd = args[0] as? [Int64] {
                        
                        DispatchQueue.global().sync {
                            
                            var lastMessageData : RPC.Message!
                            var i = 0
                            for msg in messagesToAdd {
                                guard let message = MessageManager.instance.messages[msg] else {return}
                                
                                if lastMessageData == nil {
                                    lastMessageData = message
                                } else {
                                    
                                }
                                
                                if message.itemType == PMFileManager.FileType.STICKER {
                                    messagesToAdd.remove(at: i)
                                    i -= 1
                                }
                                i += 1

                            }
                            
                            if !self.afterScroll {
                                messages.append(contentsOf: messagesToAdd)
                            } else {
                                messages.insert(contentsOf: messagesToAdd, at: 0)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        
                        let beforeContentSize = self.tableView.contentSize

                        self.tableView.reloadData()

                        if !self.afterScroll && self.startView {
                            if self.messages.count > 0 {
                                let index = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: index, at: .bottom, animated: false)
                                self.afterScroll = true
                                self.startView = false
                            }
                        } else {
                            
                            let afterContentSize = self.tableView.contentSize;
                            
                            let afterContentOffset = self.tableView.contentOffset;

                            let newContentOffset = CGPoint(x: afterContentOffset.x, y: afterContentOffset.y + afterContentSize.height - beforeContentSize.height);
                                
                            self.tableView.contentOffset = newContentOffset;
                            self.view.layoutIfNeeded()
                            
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
        guard let photo = sender.view as? CircularImageView else {return}
        
        guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
        friendProfileVC.id = photo.fromId

        friendProfileVC.fromChat = false
        
        navigationController?.pushViewController(friendProfileVC, animated: true)
        
    }
    
}

extension ChatViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let message = MessageManager.instance.messages[messages[indexPath.row]] {
            if message.from_id == User.currentUser!.id {
                if message.itemType == nil || message.itemType == .NONE {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageViewCell") as! ChatMessageViewCell
                    cell.messageLabel.text = message.text
                    cell.timeLabel.text = Utils.formatChatDateTime(timestamp: Int64(message.date), format24h: false)
                    cell.messageLabel.sizeToFit()
                    return cell
                }
            } else {
                if isGroup {
                    if message.itemType == nil || message.itemType == .NONE {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatMessageRcvViewCell") as! GroupChatMessageRcvViewCell
                        cell.messageLabel.text = message.text
                        cell.messageLabel.sizeToFit()
                        cell.timeLabel.text = Utils.formatChatDateTime(timestamp: Int64(message.date), format24h: false)
                        cell.photo.loadPhoto(url: (MessageManager.instance.users[message.from_id]?.photoUrl.url)!)
                        cell.photo.fromId = message.from_id
                        
                        let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.clickPhoto(_:)))
                        cell.photo.isUserInteractionEnabled = true
                        cell.photo.addGestureRecognizer(tapPhoto)
                        
                        let user = MessageManager.instance.users[message.from_id]
                        cell.name.text = Utils.formatUserName(user!)
                        return cell
                    }
                } else {
                    if message.itemType == nil || message.itemType == .NONE {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageRcvViewCell") as! ChatMessageRcvViewCell
                        cell.messageLabel.text = message.text
                        cell.timeLabel.text = Utils.formatChatDateTime(timestamp: Int64(message.date), format24h: false)
                        cell.messageLabel.sizeToFit()
                        return cell
                    }
                }
            }
        }
        return UITableViewCell()
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y == 0 && !startView {
            afterScroll = true

            MessageManager.instance.loadMessages(chatID: chatID, count: 40, offset: Int32(messages.count), isGroup: isGroup)
        }
    }
    
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
