//
// Created by Vladislav on 28/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//
import Foundation
import UIKit
import web3swift
import Contacts
import ContactsUI

class ChatsViewController: PaymonViewController, NotificationManagerListener, UISearchBarDelegate {
    public class CellChatData {
        var photoID:Int64!
        var name = ""
        var lastMessageText = ""
        var timeString = ""
        var time:Int64 = 0
        var chatID:Int32!
    }
    
    public class CellDialogData : CellChatData {
        
    }
    public class CellGroupData : CellChatData {
        public var lastMsgPhoto:RPC.PM_photo?
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var chatsTable: UITableView!
    
    var list:[CellChatData] = []
    var filteredChats : [CellChatData] = []
    var isLoading:Bool = false

    var refresher: UIRefreshControl!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationManager.instance.addObserver(self, id: NotificationManager.dialogsNeedReload)
        NotificationManager.instance.addObserver(self, id: NotificationManager.userAuthorized)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didDisconnectedFromServer)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didReceivedNewMessages)
        
        isLoading = false
        if (User.isAuthenticated) {
            isLoading = true
            self.navigationItem.title = "Update...".localized

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
        list.removeAll()
        
        setLayoutOptions()
        
        chatsTable.dataSource = self
        chatsTable.delegate = self
        searchBar.delegate = self
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ChatsViewController.refresh), for: UIControlEvents.valueChanged)
        chatsTable.addSubview(refresher)
        
    }
    
    @objc func refresh() {
        
        DispatchQueue.main.async {
            NotificationManager.instance.postNotificationName(id: NotificationManager.dialogsNeedReload)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredChats = list
            chatsTable.reloadData()
            return
        }
        
        filteredChats = list.filter({chat -> Bool in
            return chat.name.lowercased().contains(searchText.lowercased())
        })
        
        chatsTable.reloadData()
    }
    
    func searchBarCancelButtonShow(show : Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBar.showsCancelButton = show
            self.view.layoutIfNeeded()
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.searchBarCancelButtonShow(show: false)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("hey")
        self.searchBarCancelButtonShow(show: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarCancelButtonShow(show: false)
    }
    
    func setLayoutOptions() {
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.navigationItem.title = "Chats".localized
        
        searchBar.textField?.textColor = UIColor.white.withAlphaComponent(0.8)
        searchBar.placeholder = "Search for users or groups".localized
        searchBar.showsCancelButton = false
        
    }
    
    @IBAction func onClickAddContact(_ sender: Any) {
        self.navigationItem.title = "Chats".localized

        guard let vc = StoryBoard.chat.instantiateViewController(withIdentifier: "AddContactViewController") as? AddContactViewController else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let mute = muteAction(at: indexPath)
        let clear = clearAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [delete, clear, mute])
    }
    
    @available(iOS 11.0, *)
    func muteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Mute") { (action, view, completion) in
            //TODO: set mute chat
            completion(true)
        }
        
        action.image = #imageLiteral(resourceName: "Mute")
        action.backgroundColor = UIColor.AppColor.ChatsAction.blue
        
        return action
        
    }
    
    @available(iOS 11.0, *)
    func clearAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Clear") { (action, view, completion) in
            //TODO: clear chat history
            completion(true)
        }
        
        action.image = #imageLiteral(resourceName: "History")
        action.backgroundColor = UIColor.AppColor.ChatsAction.orange
        
        return action
        
    }
    
    @available(iOS 11.0, *)
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            //TODO: delete chat
            completion(true)
        }
        
        action.image = #imageLiteral(resourceName: "Delete")
        action.backgroundColor = UIColor.AppColor.ChatsAction.red
        
        return action
        
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
            
            self.navigationItem.title = "Chats".localized

            if !array.isEmpty {
                array.sort {
                    $0.time > $1.time
                }
                list.removeAll()
                list.append(contentsOf: array)
                
                filteredChats = list
                chatsTable.reloadData()
            } else {
            }
            
            isLoading = false
        } else if (id == NotificationManager.didDisconnectedFromServer) {
            isLoading = false
            DispatchQueue.main.async {
                self.navigationItem.title = "Chats".localized
            }
        } else if id == NotificationManager.userAuthorized {
            if !isLoading {
                isLoading = true
                DispatchQueue.main.async {

                    self.navigationItem.title = "Update...".localized

                }
                MessageManager.instance.loadChats(!NetworkManager.instance.isConnected)
            }
        }
        DispatchQueue.main.async {
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
        }
    }
}

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = indexPath.row
        let data = filteredChats[row]
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
        let data = filteredChats[row]
        tableView.deselectRow(at: indexPath, animated: true)
        let chatViewController = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as! ChatViewController
        chatViewController.setValue(data.name, forKey: "title")
        if data is CellGroupData {
            chatViewController.isGroup = true
        } else {
            chatViewController.isGroup = false
        }
        chatViewController.chatID = data.chatID
        
        self.navigationItem.title = "Chats".localized

        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}
