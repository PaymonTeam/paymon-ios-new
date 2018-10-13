//
// Created by Vladislav on 28/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//
import Foundation
import UIKit
//import web3swift
import Contacts
import ContactsUI

class ChatsViewController: PaymonViewController, NotificationManagerListener, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var chatsTable: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var list:[CellChatData] = []
    var groupsList:[CellChatData] = []
    var dialogsList:[CellChatData] = []

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
    
    
    @IBAction func segmentChanges(_ sender: Any) {
        setChatsList()
    }
    
    func setChatsList() {
        switch segment.selectedSegmentIndex {
        case 0:
            filteredChats = dialogsList
        case 1:
            filteredChats = list
        case 2:
            filteredChats = groupsList
        default:
            break
        }
        chatsTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationManager.instance.removeObserver(self, id: NotificationManager.dialogsNeedReload)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.userAuthorized)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.didDisconnectedFromServer)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.didReceivedNewMessages)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        
        chatsTable.dataSource = self
        chatsTable.delegate = self
        searchBar.delegate = self
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ChatsViewController.refresh), for: UIControl.Event.valueChanged)
        chatsTable.addSubview(refresher)
    }
    
    @objc func refresh() {
        
        DispatchQueue.main.async {
            NotificationManager.instance.postNotificationName(id: NotificationManager.dialogsNeedReload)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            setChatsList()
            chatsTable.reloadData()
            return
        }
        
        switch segment.selectedSegmentIndex {
        case 0:
            filteredChats = dialogsList.filter({chat -> Bool in
                return chat.name.lowercased().contains(searchText.lowercased())
            })
        case 1:
            filteredChats = list.filter({chat -> Bool in
                return chat.name.lowercased().contains(searchText.lowercased())
            })
        case 2:
            filteredChats = groupsList.filter({chat -> Bool in
                return chat.name.lowercased().contains(searchText.lowercased())
            })
        default:
            break
        }
        
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
        self.searchBarCancelButtonShow(show: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBarCancelButtonShow(show: false)
    }
    
    func setLayoutOptions() {
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.navigationItem.title = "Update...".localized

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
        searchBar.placeholder = "Search for users or groups".localized
        searchBar.showsCancelButton = false
        
        segment.setTitle("Dialogs".localized, forSegmentAt: 0)
        segment.setTitle("All".localized, forSegmentAt: 1)
        segment.setTitle("Groups".localized, forSegmentAt: 2)

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
            
            self.filteredChats.removeAll()
            self.dialogsList.removeAll()
            self.groupsList.removeAll()
            self.list.removeAll()
            
            var arrayAll:[CellChatData] = []
            var arrayGroups:[CellChatData] = []
            var arrayDialogs:[CellChatData] = []

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
                data.photoUrl = user.photoUrl

                data.name = username
                data.lastMessageText = lastMessageText
                data.timeString = lastMessageTime
                
                arrayDialogs.append(data)
                arrayAll.append(data)
                
                if !arrayDialogs.isEmpty {
                    arrayDialogs.sort {
                        $0.time > $1.time
                    }
                    
                }
                
            }
            
            dialogsList.append(contentsOf: arrayDialogs)
            
            for group in MessageManager.instance.groups.values {
                
                let data = CellGroupData()
                
                let title = group.title
                var lastMessageText = ""
                var lastMessageTimeString = ""
                
                var lastMsgPhoto:RPC.PM_photoURL? = nil
                if let lastMessageID = MessageManager.instance.lastGroupMessages[group.id] {
                    if let msg = MessageManager.instance.messages[lastMessageID] {
                        if msg is RPC.PM_message {
                            lastMessageText = msg.text
                            data.lastMessageType = .NONE
                        } else if msg is RPC.PM_messageItem {
                            if msg.action is RPC.PM_messageActionGroupCreate {
                                lastMessageText = "Group chat created".localized
                                data.lastMessageType = .ACTION
                            }
                        }
                        data.time = Int64(msg.date)
                        lastMessageTimeString = Utils.formatDateTime(timestamp: Int64(msg.date), format24h: true)
                        
                        let user = MessageManager.instance.users[msg.from_id]
                        if (user != nil) {
                            lastMsgPhoto = user!.photoUrl
                        }
                    }
                }

                data.chatID = group.id
                data.photoUrl = group.photoUrl

                data.name = title!
                data.lastMessageText = lastMessageText
                data.timeString = lastMessageTimeString
                data.lastMsgPhoto = lastMsgPhoto
                
                arrayGroups.append(data)
                arrayAll.append(data)

                if !arrayGroups.isEmpty {
                    arrayGroups.sort {
                        $0.time > $1.time
                    }
                }
            }
            
            groupsList.append(contentsOf: arrayGroups)

            self.navigationItem.title = "Chats".localized

            if !arrayAll.isEmpty {
                arrayAll.sort {
                    $0.time > $1.time
                }
                
                list.append(contentsOf: arrayAll)
                
                setChatsList()
                chatsTable.reloadData()
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
        print("reload")

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
//            print("url \(String(describing: data.photoUrl.url))")
            cell.photo.loadPhoto(url: data.photoUrl.url)
            return cell
        } else if data is CellGroupData {
            let groupData = data as! CellGroupData
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableGroupViewCell") as! ChatsTableGroupViewCell
            cell.title.text = groupData.name
            cell.lastMessageText.text = groupData.lastMessageText
            cell.lastMessageTime.text = groupData.timeString
            cell.photo.loadPhoto(url: groupData.photoUrl.url)
            if groupData.lastMsgPhoto != nil {
                cell.lastMessagePhoto.loadPhoto(url: (groupData.lastMsgPhoto?.url)!)
            }
            if groupData.lastMessageType == .ACTION {
                cell.lastMessageText.textColor = UIColor.AppColor.Blue.primaryBlue.withAlphaComponent(0.6)
            } else {
                cell.lastMessageText.textColor = UIColor.white.withAlphaComponent(0.6)

            }
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
        print(data.chatID)
        
        self.navigationItem.title = "Chats".localized

        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}
