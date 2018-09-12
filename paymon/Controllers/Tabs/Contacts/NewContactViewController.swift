//
//  NewContactViewController.swift
//  paymon
//
//  Created by SHUBHAM AGARWAL on 29/08/18.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class NewContactViewController: PaymonViewController, NotificationManagerListener {
    
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
    
    @IBOutlet weak var inviteFriendsView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    
    @IBOutlet weak var inviteFriends: UIButton!
    var isLoading:Bool = false
    
    var list:[CellChatData] = []
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var cnContacts  = [CNContact]()
    var contacts = [Contact]()
    var outputDict = [String:[Contact]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        list.removeAll()
        navigationBar.topItem?.title = "Contacts".localized
        
    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.navigationBar.topItem?.title = "Contacts".localized
        navigationBar.setTransparent()
        
        searchBar.textField?.textColor = UIColor.white.withAlphaComponent(0.8)
        searchBar.placeholder = "Search for users or groups".localized
        inviteFriendsView.layer.cornerRadius = inviteFriendsView.frame.height/2
        inviteFriends.setTitle("Invite friends".localized, for: .normal)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationManager.instance.addObserver(self, id: NotificationManager.dialogsNeedReload)
        NotificationManager.instance.addObserver(self, id: NotificationManager.userAuthorized)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didDisconnectedFromServer)
        NotificationManager.instance.addObserver(self, id: NotificationManager.didReceivedNewMessages)
        
        isLoading = false
        if (User.isAuthenticated) {
            isLoading = true
            navigationBar.topItem?.title = "Update...".localized
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getContacts() {
        contacts.removeAll()
        outputDict.removeAll()
        let store = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.retrieveContactsWithStore(store: store)
            
        // This is the method we will create
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.retrieveContactsWithStore(store: store)
                
            }
        default:
            print("Not handled")
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        cnContacts = [CNContact]()
        
        
        request.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stop) -> Void in
                self.cnContacts.append(contact)
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        for contact in cnContacts {
            let name = contact.givenName
            let email = String(contact.emailAddresses.first?.value ?? "N/A")
            let phone = contact.phoneNumbers.first?.value.stringValue
            let con = Contact(name: name, email: email, phone: phone)
            contacts.append(con)
        }
        
        
        for contact in contacts {
            if let value = contact.name?.isEmpty, !value {
                let initialLetter = contact.name?.substring(toIndex: 1) .uppercased()
                if initialLetter != "" {
                    var letterArray = outputDict[initialLetter!] ?? [Contact]()
                    letterArray.append(contact)
                    outputDict[initialLetter!]=letterArray
                }
            }
        }
        
        
        DispatchQueue.main.async {
            self.contactTableView.reloadData()
        }
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
            
            navigationBar.topItem?.title = "Contacts".localized

            if !array.isEmpty {
                array.sort {
                    $0.time > $1.time
                }
                list.removeAll()
                list.append(contentsOf: array)
                self.getContacts()

               // contactTableView.reloadData()
            } else {
            }
            
            isLoading = false
        } else if (id == NotificationManager.didDisconnectedFromServer) {
            isLoading = false
            DispatchQueue.main.async {
                self.navigationBar.topItem?.title = "Contacts".localized
            }
        } else if id == NotificationManager.userAuthorized {
            if !isLoading {
                isLoading = true
                DispatchQueue.main.async {
                    self.navigationBar.topItem?.title = "Update...".localized
                }
                MessageManager.instance.loadChats(!NetworkManager.instance.isConnected)
            }
        }
    }
    
}

extension NewContactViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return outputDict.count + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return list.count
        } else {
            let a = Array(outputDict.keys).sorted()
            return (outputDict[a[section - 1]]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            let a = Array(outputDict.keys).sorted()
            return a[section - 1 ]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactWasTableViewCell") as! ContactWasTableViewCell
            let data = list[indexPath.row]
            cell.name.text = data.name
            cell.timeWhenWas.text = "Was online ".localized + "\(data.timeString)"
            cell.avatar.setPhoto(ownerID: data.chatID, photoID: data.photoID)
            return cell
        } else {
        let a = Array(outputDict.keys).sorted()
        let data = outputDict[a[indexPath.section - 1]]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.name.text = data?[indexPath.row].name
            
//        if data is CellDialogData {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsTableViewCell") as! ChatsTableViewCell
//            cell.title.text = data.name
//            cell.lastMessageText.text = data.lastMessageText
//            cell.lastMessageTime.text = data.timeString
//            cell.photo.setPhoto(ownerID: data.chatID, photoID: data.photoID)
//            return cell
//        }
        
        return cell
        }
    }
}
extension NewContactViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel?.textAlignment = .right
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let row = indexPath.row
            let data = list[row]
            tableView.deselectRow(at: indexPath, animated: true)
            let chatView = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatView.setValue(data.name, forKey: "title")
            chatView.chatID = data.chatID
            chatView.isGroup = false
            present(chatView, animated: false, completion: nil)
        } else {
            let a = Array(outputDict.keys).sorted()
            let data = outputDict[a[indexPath.section - 1]]
            let detailView = StoryBoard.contacts.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
            detailView.contact = data?[indexPath.row]
            navigationController?.pushViewController(detailView, animated: true)
        }
    }
}
