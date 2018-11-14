//
// Created by Vladislav on 01/09/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit
import UserNotifications
import CoreStore
import ReverseExtension
import MBProgressHUD

class ChatViewController: PaymonViewController, ListSectionObserver {
    typealias ListEntityType = ChatMessageData
    
    @IBOutlet weak var messageTextView: UITextView!

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sendButtonImage: UIImageView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintViewBottom: NSLayoutConstraint!

    @IBOutlet weak var chatTitle: UILabel!
    @IBOutlet weak var chatSubtitle: UILabel!
    @IBOutlet weak var customTitleView: UIView!
    var messages : ListMonitor<ChatMessageData>!
    var reverseSections : [Int] = []
    var chatID: Int32!
    var isGroup: Bool!
    var startView = true
    var messageCountForUpdate : Int! = 0
    var firstLoaded = false
    
    @IBAction func onSendClicked() {
        guard let text = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty, text != "To write a message".localized else {return}
        messageTextView.text = ""
        textViewDidChange(messageTextView)
        MessageManager.shared.sendMessage(text: text, isGroup: isGroup, chatId: chatID)
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
        
        if isGroup {
            if let group = GroupDataManager.shared.getGroupById(id: chatID) {
                var text = "Participants: ".localized
                text.append("\(group.users.count)")
                
                chatSubtitle.text = text
            }
            
        } else {
            chatSubtitle.text = "online"
        }
    }
    
    @IBAction func titleClick(_ sender: Any) {
        
        if isGroup {
            guard let groupSettingVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.groupSettingViewController) as? GroupSettingViewController else {return}
            groupSettingVC.groupId = chatID
            
            navigationController?.pushViewController(groupSettingVC, animated: true)
        } else {
            guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
            friendProfileVC.id = chatID
            friendProfileVC.fromChat = true
            
            navigationController?.pushViewController(friendProfileVC, animated: true)
        }
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<ChatMessageData>) {
        self.tableView.reloadData()
    }
    
    func listMonitorWillChange(_ monitor: ListMonitor<ChatMessageData>) {
        self.tableView.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<ChatMessageData>) {
        self.tableView.endUpdates()
        if !firstLoaded {
            self.reloadChat()
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didInsertObject object: ChatMessageData, toIndexPath indexPath: IndexPath) {

        if object.toId == chatID {
                self.tableView.re.insertRows(at: [indexPath], with: .none)
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didDeleteObject object: ChatMessageData, fromIndexPath indexPath: IndexPath) {
        self.tableView.re.deleteRows(at: [indexPath], with: .left)

    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
            self.tableView.re.insertSections(IndexSet(integer: sectionIndex), with: .none)
    }
    
    func listMonitor(_ monitor: ListMonitor<ChatMessageData>, didUpdateObject object: ChatMessageData, atIndexPath indexPath: IndexPath) {
        
        let message = messages[indexPath]
        
        if let cell = tableView.re.cellForRow(at: indexPath) as? ChatMessageViewCell {
            cell.configure(message: message)
        } else if let cell = tableView.re.cellForRow(at: indexPath) as? GroupChatMessageRcvViewCell {
            cell.configure(message: message)
            if cell.photo.gestureRecognizers?.count != 0 {
                let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.clickPhoto(_:)))
                cell.photo.isUserInteractionEnabled = true
                cell.photo.addGestureRecognizer(tapPhoto)
            }
        } else if let cell = tableView.re.cellForRow(at: indexPath) as?  ChatMessageRcvViewCell {
            cell.configure(message: message)
        }
    }
    
    func showTable() {
        print("Show table")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
    }
    
    func setMessages() {
        messages = MessageDataManager.shared.getMessagesByChatId(chatId: chatID)
        
        messages.addObserver(self)

        if messages.numberOfObjects() == 1 {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        } else {
            firstLoaded = true
            showTable()
        }
        
        loadMessages(offset: 0, count : 30)
    }
    
    func reloadChat() {
        if messages.numberOfObjects() == messageCountForUpdate {
            showTable()
            firstLoaded = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)

        setLayoutOptions()
        
        tableView.re.delegate = self
        tableView.re.dataSource = self
        messageTextView.delegate = self
        
        setMessages()
        
        self.tableView.re.scrollViewDidReachTop = { scrollView in
            if self.firstLoaded {
                print("top")
//                self.loadMessages(offset: 10, count: 10)
            }
        }

    }

    @objc func handleKeyboardNotification(notification: NSNotification) {

        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect

            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification

            constraintViewBottom.constant = isKeyboardShowing ? -keyboardFrame!.height : 0

            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        messages.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
        
        if let nc = UIApplication.shared.keyWindow?.rootViewController as? MainNavigationController {
            nc.navigationBar.isHidden = true
        }
        
    }
    
    @objc func clickPhoto(_ sender : UITapGestureRecognizer) {
        guard let photo = sender.view as? CircularImageView else {return}
        
        guard let friendProfileVC = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.friendProfileViewController) as? FriendProfileViewController else {return}
        friendProfileVC.id = photo.fromId
        friendProfileVC.fromChat = false
        
        navigationController?.pushViewController(friendProfileVC, animated: true)
        
    }
 
    public func loadMessages(offset : Int32, count : Int32) {
        if User.currentUser == nil || chatID == 0 {
            return
        }
        let packet = RPC.PM_getChatMessages()
        
        packet.chatID = isGroup ? RPC.PM_peerGroup(group_id: chatID) : RPC.PM_peerUser(user_id: chatID)
        packet.count = count
        packet.offset = offset
        
        NetworkManager.shared.sendPacket(packet) {response, e in
            if response == nil { return }
            if let packet = response as? RPC.PM_chatMessages {
                if (packet.messages.count != 0) {
                    self.messageCountForUpdate = packet.messages.count
                    print("message count update \(self.messageCountForUpdate)")
                    self.reloadChat()
                    MessageDataManager.shared.updateMessages(packet.messages)
                }
            }
        }
    }
    
    public func reverseSection(sectionsCount : Int) {
        reverseSections = []
        for i in 0..<sectionsCount {
            reverseSections.append(i)
        }
        reverseSections.sort {
            return $0 > $1
        }
    }
    
}


extension ChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionsCount = messages.numberOfSections()
        reverseSection(sectionsCount: sectionsCount)
        
        return sectionsCount
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.numberOfObjectsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let message = messages[indexPath] as ChatMessageData? {
            if message.fromId == User.currentUser!.id {
                if message.itemType == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageViewCell", for: indexPath) as! ChatMessageViewCell
                    cell.configure(message: message)
                    return cell
                } else if message.itemType == 5 {
                    if let group = GroupDataManager.shared.getGroupById(id: message.toId) {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableCretedGroupCell") as! ChatsTableCretedGroupCell
                        cell.configure(group : group)
                        return cell
                    }
                }
            } else {
                if isGroup {
                    if message.itemType == 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatMessageRcvViewCell") as! GroupChatMessageRcvViewCell
                        cell.configure(message: message)
                        let tapPhoto = UITapGestureRecognizer(target: self, action: #selector(self.clickPhoto(_:)))
                        cell.photo.isUserInteractionEnabled = true
                        cell.photo.addGestureRecognizer(tapPhoto)
                        return cell
                    } else if message.itemType == 5 {
                        if let group = GroupDataManager.shared.getGroupById(id: message.toId) {
                            if let creator = UserDataManager.shared.getUserById(id: group.creatorId) {
                                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableCretedGroupCell") as! ChatsTableCretedGroupCell
                                cell.label.text = "\(Utils.formatUserDataName(creator)) "+"created the group chat ".localized+"\"\(group.title!)\""
                                return cell
                            }
                        }
                    }
                } else {
                    if message.itemType == 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageRcvViewCell") as! ChatMessageRcvViewCell
                        cell.configure(message: message)
                        return cell
                    }
                }
            }
        }
        
        return UITableViewCell()
    }
    
}

extension ChatViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTextView.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let label = UILabel()
        label.text = messages.sectionInfoAtIndex(safeSectionIndex: reverseSections[section])!.name
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.center = tableView.center
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        return label
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
