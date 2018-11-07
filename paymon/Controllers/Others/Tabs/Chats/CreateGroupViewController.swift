//
//  CreateGroupViewController.swift
//  paymon
//
//  Created by infoobjects on 5/21/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreateGroupViewController: PaymonViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var btnCreateGroup: UIBarButtonItem!
    @IBOutlet weak var tblVContacts: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var participantsFromGroup : [UserData] = []
    
    var usersData:[UserData] = []
    var selectedUserData:NSMutableArray = []
    var isGroupAlreadyCreated:Bool = false
    var chatID: Int32!
    
    var filteredOutput = [String:[UserData]]()
    
    var outputDict = [String:[UserData]]()
    var tableSection = [String]()
    var saveSelected = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var i = 0
        let count = participantsFromGroup.count
        
        for user in UserDataManager.shared.getUserByContact(isContact: true)! {
            
            print("login: \(user.login), isContact \(user.isContact)")
            if user.id == User.currentUser.id {
                continue
            }
            
            for part in participantsFromGroup {
                if user.id != part.id {
                    i += 1
                }
            }
            
            if i == count {
                usersData.append(user)
            }
            i = 0
            
        }
        
        getUsersDict()

        setLayoutOptions()
        searchBar.delegate = self
        self.navigationController?.delegate = self
    }
    
    func moveToChat(group : RPC.Group) {
        var navigationArray = self.navigationController?.viewControllers //To get all UIViewController stack as Array
        navigationArray!.remove(at: (navigationArray?.count)! - 2)
        navigationArray!.remove(at: (navigationArray?.count)! - 1)
        
        guard let chatViewController = StoryBoard.chat.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as? ChatViewController else {return}
        chatViewController.chatID = group.id
        chatViewController.isGroup = true
        chatViewController.setValue(group.title, forKey: "title")
        navigationArray!.append(chatViewController)
        
        DispatchQueue.main.async {
            self.navigationController?.viewControllers = navigationArray!
        }
    }
    
    func getUsersDict() {
        for user in usersData {
            
            let key = Utils.formatUserDataName(user)
            
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
        
        searchBar.placeholder = "Search for users".localized

        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        if isGroupAlreadyCreated {
            self.title = "Add".localized
        } else {
            self.title = "Create group".localized
        }
        
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
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        if saveSelected {
            guard let settingsGroupVC = viewController as? GroupSettingViewController else {return}
            
            if selectedUserData.count != 0 {
                for user in selectedUserData {
                    if let data = user as? UserData {
                        settingsGroupVC.participants.append(data)
                        settingsGroupVC.group.users.append(data.id)
                        GroupDataManager.shared.updateGroup(groupObject: settingsGroupVC.group)
                    }
                }
                
                settingsGroupVC.tableViewParticipants.reloadData()
            }
        }
        
    }
    
    //MARK: - IBActions
    
    @IBAction func createGroupAction(_ sender: Any) {
        
        if isGroupAlreadyCreated {
            
            let addParticipant:RPC.PM_group_addParticipants! =  RPC.PM_group_addParticipants();
            addParticipant.userIDs = []
            for user in self.selectedUserData {
                if let data = user as? UserData {
                    addParticipant.userIDs.append(data.id)
                }
            }
            if addParticipant.userIDs.isEmpty {
                return ;
            }
            
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            addParticipant.id = chatID;
            NetworkManager.shared.sendPacket(addParticipant) { response, e in
                
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                if response is RPC.PM_boolTrue {
                    self.saveSelected = true
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.saveSelected = false
                }
            }
        } else {
            if selectedUserData.count > 0 {
                let alert = UIAlertController(title: "Create group".localized, message: "Enter group name".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
                    
                }))
                alert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { (nil) in
                    let textField = alert.textFields![0] as UITextField
                    if !(textField.text?.isEmpty)! {
                        let createGroup = RPC.PM_createGroup()
                        createGroup.userIDs = []
                        for user in self.selectedUserData {
                            let data = user as! UserData
                            createGroup.userIDs.append(data.id)
                        }
                        createGroup.title = textField.text;
                        let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
                        
                        NetworkManager.shared.sendPacket(createGroup) { response, e in
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: self.view, animated: true)
                            }
                            if (response != nil) {
                                let group:RPC.Group! = response as! RPC.Group?
                                GroupDataManager.shared.updateGroup(groupObject: group)
                                self.moveToChat(group: group)
                            }
                        }
                    }
                }))
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter group title".localized
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = tableSection[indexPath.section]
        if let users = filteredOutput[key] {
            let user = users[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupContactsTableViewCell") as! GroupContactsTableViewCell
            cell.configure(data: user)
            cell.accessoryType = selectedUserData.contains(user) ? .checkmark : .none
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
        
        return String(tableSection[section].first!)
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
