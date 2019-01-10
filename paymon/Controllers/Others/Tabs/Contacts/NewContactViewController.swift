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
import CoreStore

class NewContactViewController: PaymonViewController, UISearchBarDelegate {
    
    @IBOutlet weak var inviteFriendsView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    
    @IBOutlet weak var inviteFriends: UIButton!
    var isLoading:Bool = false
    
    var existUsersArray:[ChatsData] = []
    var existUsersFilteredArray:[ChatsData] = []

    
    var cnContacts  = [CNContact]()
    var contacts = [Contact]()
    var phoneContactsDict = [String:[Contact]]()
    var phoneContactsFilteredDict = [String:[Contact]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        
        existUsersArray.removeAll()
        self.getContacts()
        self.getContactsFromCache()
        
        searchBar.delegate = self

    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.navigationItem.title = "Contacts".localized
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8)]

        searchBar.placeholder = "Search for users or groups".localized
        inviteFriendsView.layer.cornerRadius = inviteFriendsView.frame.height/2
        inviteFriends.setTitle("Invite friends".localized, for: .normal)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
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
            return chat.title.lowercased().contains(searchText.lowercased())
        })
        
        if phoneContactsFilteredDict.isEmpty && existUsersFilteredArray.isEmpty {
            
            let searchContact = RPC.PM_searchContact()
            searchContact.query = searchText.lowercased()
            NetworkManager.shared.sendPacket(searchContact) { packet, error in
                if let usersPacket = packet as? RPC.PM_users {
                    for packetUser in usersPacket.users {
                        
                        let data = ChatsData(context: (CoreStore.defaultStack.unsafeContext()))
                        
                        data.id = packetUser.id
                        data.photoUrl = packetUser.photoUrl.url
                        data.title = Utils.formatUserName(packetUser)

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
    
    func getContactsFromCache() {
        
        existUsersArray = ChatsDataManager.shared.getChatsDataByChatType(isGroup: false)
        existUsersFilteredArray = existUsersArray

        contactTableView.reloadData()
        
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
            cell.configure(data: data)
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
            guard let chatViewController = StoryBoard.chat.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as? ChatViewController else {return}
            chatViewController.setValue(data.title, forKey: "title")
            chatViewController.chatID = data.id
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
