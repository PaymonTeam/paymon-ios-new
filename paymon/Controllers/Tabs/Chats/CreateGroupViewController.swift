//
//  CreateGroupViewController.swift
//  paymon
//
//  Created by infoobjects on 5/21/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import UIKit

class GroupContactsTableViewCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: ObservableImageView!
}

class CreateGroupViewController: PaymonViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    @IBOutlet weak var btnCreateGroup: UIBarButtonItem!
    @IBOutlet weak var tblVContacts: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var usersData:[RPC.UserObject] = []
    var selectedUserData:NSMutableArray = []
    var isGroupAlreadyCreated:Bool = false
    var chatID: Int32!
    
    var filteredOutput = [String:[RPC.UserObject]]()
    
    var outputDict = [String:[RPC.UserObject]]()
    var tableSection = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        for user in MessageManager.instance.userContacts.values {
            usersData.append(user)
        }
        
        getUsersDict()
        
        if isGroupAlreadyCreated {
            let navigationItem = UINavigationItem()
            navigationItem.title = value(forKey: "title") as? String
            if navigationBar.items != nil {
                navigationBar.items!.append(navigationItem)
            }
        }

        setLayoutOptions()
        searchBar.delegate = self
    }
    
    func getUsersDict() {
        for user in usersData {
            
            let key = Utils.formatUserName(user).substring(toIndex: 1).uppercased()
            
            if  var users = outputDict[key] {
                users.append(user)
                outputDict[key] = users
            } else {
                outputDict[key] = [user]
            }
            
            tableSection = [String](outputDict.keys).sorted()
        }
        
        filteredOutput = outputDict
        
        DispatchQueue.main.async {
            self.tblVContacts.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setLayoutOptions() {
        searchBar.textField?.textColor = UIColor.white.withAlphaComponent(0.8)
        searchBar.placeholder = "Search for users".localized

        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Create group".localized
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredOutput = outputDict
            tableSection = [String](outputDict.keys).sorted()
            tblVContacts.reloadData()
            return
        }

        filteredOutput = outputDict.filter({user -> Bool in
            
            return user.key.lowercased().contains(searchText.lowercased())
        })
        tableSection = [String](filteredOutput.keys).sorted()

        


        tblVContacts.reloadData()
    }
    
    //MARK: - IBActions
    
    @IBAction func createGroupAction(_ sender: Any) {
        if isGroupAlreadyCreated {
            let addParticipant:RPC.PM_group_addParticipants! =  RPC.PM_group_addParticipants();
            addParticipant.userIDs = []
            for user in self.selectedUserData {
                let data = user as! RPC.UserObject
                addParticipant.userIDs.append(data.id)
            }
            if addParticipant.userIDs.isEmpty {
                return ;
            }
            
            addParticipant.id = chatID;
            NetworkManager.instance.sendPacket(addParticipant) { response, e in
                _ = MessageManager.instance
                if (response != nil) {
                    let _:RPC.Group! = response as! RPC.Group?
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            if selectedUserData.count > 0 {
                let alert = UIAlertController(title: "Create group".localized, message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
                    
                }))
                alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (nil) in
                    let textField = alert.textFields![0] as UITextField
                    if !(textField.text?.isEmpty)! {
                        let createGroup = RPC.PM_createGroup()
                        createGroup.userIDs = []
                        for user in self.selectedUserData {
                            let data = user as! RPC.UserObject
                            createGroup.userIDs.append(data.id)
                        }
                        createGroup.title = textField.text;
                        NetworkManager.instance.sendPacket(createGroup) { response, e in
                            let manager = MessageManager.instance
                            if (response != nil) {
                                let group:RPC.Group! = response as! RPC.Group?
                                manager.putGroup(group)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }))
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter group title"
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = tableSection[indexPath.section]
        if let users = filteredOutput[key] {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupContactsTableViewCell") as! GroupContactsTableViewCell
            cell.name.text = Utils.formatUserName(users[indexPath.row])
            cell.photo.setPhoto(ownerID: users[indexPath.row].id, photoID: users[indexPath.row].photoID)
            
            cell.accessoryType = selectedUserData.contains(users[indexPath.row]) ? .checkmark : .none
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel?.textAlignment = .right
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = tableSection[indexPath.section]
        if let users = filteredOutput[key] {
            tableView.deselectRow(at: indexPath, animated: true)
            if selectedUserData.contains(users[indexPath.row]) {
                selectedUserData.removeObject(identicalTo: users[indexPath.row])
            } else {
                selectedUserData.add(users[indexPath.row])
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSection[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = tableSection[section]
        if let users = filteredOutput[key] {
            return users.count
        }
        
        return 0
    }
}
