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

class NewContactViewController: PaymonViewController, NotificationManagerListener, UISearchBarDelegate {
    
    public class CellChatData {
        var photoID:Int64!
        var name = ""
        var lastMessageText = ""
        var timeString = ""
        var time:Int64 = 0
        var chatID:Int32!
    }
    
    public class CellContactData : CellChatData {
        var login : String!
    }
    
    @IBOutlet weak var inviteFriendsView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    
    @IBOutlet weak var inviteFriends: UIButton!
    var isLoading:Bool = false
    
    var existUsersArray:[CellContactData] = []
    var existUsersFilteredArray:[CellContactData] = []

    
    var cnContacts  = [CNContact]()
    var contacts = [Contact]()
    var phoneContactsDict = [String:[Contact]]()
    var phoneContactsFilteredDict = [String:[Contact]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        
        existUsersArray.removeAll()
        self.getContacts()
        
        searchBar.delegate = self

    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.navigationItem.title = "Contacts".localized
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            phoneContactsFilteredDict = phoneContactsDict
            existUsersFilteredArray = existUsersArray
            contactTableView.reloadData()
            return
        }
        
        phoneContactsFilteredDict = phoneContactsDict.filter({contact -> Bool in
            return contact.key.lowercased().contains(searchText.lowercased())
        })
        
        existUsersFilteredArray = existUsersArray.filter({chat -> Bool in
            return chat.name.lowercased().contains(searchText.lowercased())
        })
        
        if phoneContactsFilteredDict.isEmpty && existUsersFilteredArray.isEmpty {
            print()
            let searchContact = RPC.PM_searchContact()
            searchContact.query = searchText.lowercased()
            NetworkManager.instance.sendPacket(searchContact) { packet, error in
                if let usersPacket = packet as? RPC.PM_users {
                    for packetUser in usersPacket.users {
                        guard let user = packetUser as? RPC.UserObject else {return}
                        
                        let data = CellContactData()
                        
                        let username = Utils.formatUserName(user)
                        
//                        var lastMessageTime = ""
//
//                        if let lastMessageID = MessageManager.instance.lastMessages[user.id] {
//
//                            print("last message id \(lastMessageID)")
//
//
//                            if let msg:RPC.Message = MessageManager.instance.messages[lastMessageID] {
//
//                                lastMessageTime = Utils.formatDateTime(timestamp: Int64(msg.date), format24h: true)
//                                print("last message time \(lastMessageTime)")
//                            }
//                        }
                        data.chatID = user.id
                        data.photoID = user.photoID
                        data.name = username
                        data.login = "@\(user.login!)"
                        
//                        data.timeString = lastMessageTime

                        self.existUsersFilteredArray.append(data)
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.contactTableView.reloadData()
                    }

                } else if let e = error {
                    print(e.message)
                }
                
            }
        }
        
        contactTableView.reloadData()

    }
    
    func getContacts() {
        contacts.removeAll()
        phoneContactsDict.removeAll()
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
                    var letterArray = phoneContactsDict[initialLetter!] ?? [Contact]()
                    letterArray.append(contact)
                    phoneContactsDict[initialLetter!]=letterArray
                }
            }
        }
        
        phoneContactsFilteredDict = phoneContactsDict
        
        
        DispatchQueue.main.async {
            self.contactTableView.reloadData()
        }
    }
    
    func didReceivedNotification(_ id: Int, _ args: [Any]) {
        if (id == NotificationManager.dialogsNeedReload || id == NotificationManager.didReceivedNewMessages) {
            
            var array:[CellContactData] = []
            for user in MessageManager.instance.userContacts.values {
                let data = CellContactData()
                
                let username = Utils.formatUserName(user)
                print(username)
                
                var lastMessageTime = ""
                
                if let lastMessageID = MessageManager.instance.lastMessages[user.id] {
                    if let msg:RPC.Message = MessageManager.instance.messages[lastMessageID] {
                        
                        data.time = Int64(msg.date)
                        lastMessageTime = Utils.formatDateTime(timestamp: Int64(msg.date), format24h: true)
                    }
                }
                data.chatID = user.id
                data.photoID = user.photoID
                data.name = username
                
                data.timeString = lastMessageTime
                array.append(data)
            }
            
            self.navigationItem.title = "Contacts".localized

            if !array.isEmpty {
                array.sort {
                    $0.time > $1.time
                }
                existUsersArray.removeAll()
                existUsersArray.append(contentsOf: array)
                existUsersFilteredArray = existUsersArray
                
                contactTableView.reloadData()
            } else {
            }
            
            isLoading = false
        } else if (id == NotificationManager.didDisconnectedFromServer) {
            isLoading = false
            DispatchQueue.main.async {
                self.navigationItem.title = "Contacts".localized
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
    }
    
}

extension NewContactViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return phoneContactsFilteredDict.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return existUsersFilteredArray.count
        } else {
            let a = Array(phoneContactsFilteredDict.keys).sorted()
            return (phoneContactsFilteredDict[a[section - 1]]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            let a = Array(phoneContactsFilteredDict.keys).sorted()
            return a[section - 1 ]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactWasTableViewCell") as! ContactWasTableViewCell
            let data = existUsersFilteredArray[indexPath.row]
            cell.name.text = data.name
            if !data.timeString.isEmpty {
                cell.timeWhenWas.text = "last seen ".localized + "\(data.timeString)"
            } else {
                cell.timeWhenWas.text = data.login!
            }
            cell.avatar.setPhoto(ownerID: data.chatID, photoID: data.photoID)
            return cell
        } else {
        let a = Array(phoneContactsFilteredDict.keys).sorted()
        let data = phoneContactsFilteredDict[a[indexPath.section - 1]]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        cell.name.text = data?[indexPath.row].name
        
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
        
        self.navigationItem.title = "Contacts".localized

        if indexPath.section == 0 {
            let row = indexPath.row
            let data = existUsersFilteredArray[row]
            tableView.deselectRow(at: indexPath, animated: true)
            guard let chatViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as? ChatViewController else {return}
            chatViewController.setValue(data.name, forKey: "title")
            chatViewController.chatID = data.chatID
            chatViewController.isGroup = false
            self.navigationController?.pushViewController(chatViewController, animated: true)
        } else {
            let a = Array(phoneContactsFilteredDict.keys).sorted()
            let data = phoneContactsFilteredDict[a[indexPath.section - 1]]
            guard let detailView = StoryBoard.contacts.instantiateViewController(withIdentifier: VCIdentifier.contactDetailViewController) as? ContactDetailViewController else {return}
            detailView.contact = data?[indexPath.row]
            navigationController?.pushViewController(detailView, animated: true)
        }
    }
}
