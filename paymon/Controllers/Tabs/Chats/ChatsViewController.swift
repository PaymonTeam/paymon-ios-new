//
// Created by Vladislav on 28/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit
import web3swift
import Contacts
import ContactsUI

class ChatsViewController: PaymonViewController, NotificationManagerListener {
    public class CellChatData {
        var photoID:Int64!
        var name = ""
        var lastMessageText = ""
        var timeString = ""
        var time:Int64 = 0
        var chatID:Int32!
    }
    
    @IBOutlet weak var borderConstraint: NSLayoutConstraint!
    
    public class CellDialogData : CellChatData {
        
    }
    public class CellGroupData : CellChatData {
        public var lastMsgPhoto:RPC.PM_photo?
    }
    @IBOutlet weak var chatsTable: UITableView!
    
    var list:[CellChatData] = []
    var isLoading:Bool = false
    var activityView:UIActivityIndicatorView!
    let editNavigationItem = UINavigationItem()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationManager.instance.addObserver(self, id: NotificationManager.dialogsNeedReload)
        NotificationManager.instance.addObserver(self, id: NotificationManager.userAuthorized)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didDisconnectedFromServer)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didReceivedNewMessages)
        
        isLoading = false
        if (User.isAuthenticated) {
            isLoading = true
            activityView.startAnimating()
            MessageManager.instance.loadChats(!NetworkManager.instance.isConnected)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationManager.instance.removeObserver(self, id: NotificationManager.dialogsNeedReload)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.userAuthorized)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.didDisconnectedFromServer)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.didReceivedNewMessages)
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        list.removeAll()
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        
        chatsTable.dataSource = self
        chatsTable.delegate = self
        
    }
    
    @IBAction func onClickAddContact(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
        
    func setup() {
        self.tabBarController?.tabBar.items?[0].title = "Chats".localized
        self.tabBarController?.tabBar.items?[1].title = "Contacts".localized
        self.tabBarController?.tabBar.items?[2].title = "Wallet".localized
        self.tabBarController?.tabBar.items?[3].title = "Games".localized
        self.tabBarController?.tabBar.items?[4].title = "Profile".localized

        self.navigationItem.title = "Chats".localized

        borderConstraint.constant = 0.5
    }
    @IBAction func addGroupItemClick(_ sender: Any) {
        let groupView = storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        present(groupView, animated: false, completion: nil)
    }
    
    func didReceivedNotification(_ id: Int, _ args: [Any]) {
        if (id == NotificationManager.dialogsNeedReload || id == NotificationManager.didReceivedNewMessages) {
            
            var array:[CellChatData] = []
            for user in MessageManager.instance.userContacts.values {
                let data = CellDialogData()
                
                let username = Utils.formatUserName(user)
                var lastMessageText = ""
                var lastMessageTime = ""
                
                if let lastMessageID = MessageManager.instance.lastMessages[user.id] {
                    if let msg:RPC.Message = MessageManager.instance.messages[lastMessageID] {
                        if (msg is RPC.PM_message) {
                            lastMessageText = msg.text
                        } else if (msg is RPC.PM_messageItem) {
                            lastMessageText = String(describing: msg.itemType!)
                        }
                        data.time = Int64(msg.date)
                        lastMessageTime = Utils.formatDateTime(timestamp: Int64(msg.date), format24h: true)
                    }
                }
                data.chatID = user.id
                data.photoID = user.photoID
                data.name = username
                data.lastMessageText = lastMessageText
                data.timeString = lastMessageTime
                array.append(data)
            }
            
            for group in MessageManager.instance.groups.values {
                
                let data = CellGroupData()
                
                let title = group.title
                var lastMessageText = ""
                var lastMessageTimeString = ""
                
                var lastMsgPhoto:RPC.PM_photo? = nil
                if let lastMessageID = MessageManager.instance.lastGroupMessages[group.id] {
                    if let msg = MessageManager.instance.messages[lastMessageID] {
                        if (msg is RPC.PM_message) {
                            lastMessageText = msg.text
                        } else if (msg is RPC.PM_messageItem) {
                            lastMessageText = String(describing: msg.itemType!)
                        }
                        data.time = Int64(msg.date)
                        lastMessageTimeString = Utils.formatDateTime(timestamp: Int64(msg.date), format24h: true)
                        
                        let user = MessageManager.instance.users[msg.from_id]
                        if (user != nil) {
                            lastMsgPhoto = RPC.PM_photo()
                            lastMsgPhoto!.user_id = user!.id
                            lastMsgPhoto!.id = user!.photoID
                        }
                    }
                }
                let photo = group.photo
                if (photo!.id == 0) {
                    photo!.id = MediaManager.instance.generatePhotoID()
                }
                if (photo!.user_id == 0) {
                    photo!.user_id = -group.id
                }
                data.chatID = group.id
                data.photoID = photo!.id
                data.name = title!
                data.lastMessageText = lastMessageText
                data.timeString = lastMessageTimeString
                data.lastMsgPhoto = lastMsgPhoto
                array.append(data)
            }
            
            activityView.stopAnimating()
            
            if !array.isEmpty {
                array.sort {
                    $0.time > $1.time
                }
                list.removeAll()
                list.append(contentsOf: array)
                chatsTable.reloadData()
            } else {
            }
            
            isLoading = false
        } else if (id == NotificationManager.didDisconnectedFromServer) {
            isLoading = false
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
            }
        } else if id == NotificationManager.userAuthorized {
            if !isLoading {
                isLoading = true
                DispatchQueue.main.async {
                    self.activityView.startAnimating()
                }
                MessageManager.instance.loadChats(!NetworkManager.instance.isConnected)
            }
        }
    }
}

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let data = list[row]
        if data is CellDialogData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell") as! ChatsTableViewCell
            cell.title.text = data.name
            cell.lastMessageText.text = data.lastMessageText
            cell.lastMessageTime.text = data.timeString
            cell.photo.setPhoto(ownerID: data.chatID, photoID: data.photoID)
            return cell
        } else if data is CellGroupData {
            let groupData = data as! CellGroupData
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableGroupViewCell") as! ChatsTableGroupViewCell
            cell.title.text = groupData.name
            cell.lastMessageText.text = groupData.lastMessageText
            cell.lastMessageTime.text = groupData.timeString
            if groupData.lastMsgPhoto != nil {
                cell.lastMessagePhoto.setPhoto(photo: groupData.lastMsgPhoto!)
            }
            cell.photo.setPhoto(ownerID: -groupData.chatID, photoID: groupData.photoID)
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell") as! ChatsTableViewCell
    }
}
extension ChatsViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let data = list[row]
        tableView.deselectRow(at: indexPath, animated: true)
        let chatView = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatView.setValue(data.name, forKey: "title")
        if data is CellGroupData {
            chatView.isGroup = true
        } else {
            chatView.isGroup = false
        }
        chatView.chatID = data.chatID
        
        
        present(chatView, animated: false, completion: nil)
    }
}

extension ChatsViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        print("\(contactProperty.contact)")
    }
}
