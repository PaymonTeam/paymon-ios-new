//
//  GroupSettingViewController.swift
//  paymon
//
//  Created by infoobjects on 5/26/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import UIKit
import MBProgressHUD



class GroupSettingViewController: PaymonViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var groupTitleHint: UILabel!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var groupImage: CircularImageView!
    @IBOutlet weak var tableViewParticipants: UITableView!
    @IBOutlet weak var addParticipants: UIButton!
    @IBOutlet weak var groupTitle: UITextField!

    var groupId: Int32!
    var participants = [UserData]()
    var participantsIds = [Int32]()

    var isCreator:Bool = false
    var creatorId:Int32!
    var group:GroupData!
    var newGroupTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let groupData = GroupDataManager.shared.getGroupById(id: groupId) {
            participantsIds = groupData.users
            group = groupData
        }
        
        for id in participantsIds {
            if let user = UserDataManager.shared.getUserById(id: id) {
                participants.append(user)
            }
        }
        
        groupTitle.text = group.title
        creatorId = group.creatorId
        isCreator = creatorId == User.currentUser?.id
        
        self.groupTitle.delegate = self
        self.navigationController?.delegate = self
        
        setLayoutOptions()

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case groupTitle:
            return newLength <= 128
        
        default: break
        }
        
        return true
    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        groupTitle.layer.cornerRadius = groupTitle.frame.height/2
        addView.layer.cornerRadius = addView.frame.height/2
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.groupTitle.frame.height))

        groupTitle.leftView = paddingView
        groupTitle.leftViewMode = UITextField.ViewMode.always
        
        let pickImage = UITapGestureRecognizer(target: self, action: #selector(self.openImagePicker(_:)))
        groupImage.isUserInteractionEnabled = true
        groupImage.addGestureRecognizer(pickImage)
        
        self.title = "Group".localized
        addParticipants.setTitle("Add participants".localized, for: .normal)
        groupTitleHint.text = "Group name".localized
        
        groupTitle.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.done.isEnabled = false


    }
    
    @objc func textFieldDidChanged(_ textField : UITextField) {
        if textField.text != group.title && !(textField.text?.isEmpty)!{
            self.done.isEnabled = true
        } else {
            self.done.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnAddParticipantsTapped(_ sender: Any) {
        let createGroupViewController = storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        createGroupViewController.isGroupAlreadyCreated = true
        createGroupViewController.chatID = groupId
        createGroupViewController.participantsFromGroup = participants
        
        self.navigationController?.pushViewController(createGroupViewController, animated: true)
    }
    
    @objc func openImagePicker(_ sender : UITapGestureRecognizer) {
        let cardPicker = UIImagePickerController()
        cardPicker.allowsEditing = true
        cardPicker.delegate = self
        cardPicker.sourceType = .photoLibrary
        present(cardPicker, animated: true)
        
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        GroupManager.shared.updateAvatar(groupId: self.groupId, info: info, avatarView: groupImage, vc: self)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let chatVC = viewController as? ChatViewController else {return}
        
        if !newGroupTitle.isEmpty {
            chatVC.chatTitle.text = newGroupTitle
        }
        
        var text = "Participants: ".localized
        text.append("\(group.users.count)")
        
        chatVC.chatSubtitle.text = text
        
    }

    @IBAction func btnDoneTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.done.isEnabled = false
        
        let _ = MBProgressHUD.showAdded(to: self.view, animated: true)

        let setSettings = RPC.PM_group_setSettings()
        setSettings.id = groupId;
        setSettings.title = groupTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        newGroupTitle = groupTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        NetworkManager.shared.sendPacket(setSettings) { response, e in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }

            if (response != nil) {
                
                var title = ""
                DispatchQueue.main.async {
                    title = self.groupTitle.text!
                    Utils.showSuccesHud(vc: self)
                }
                
                GroupDataManager.shared.updateGroupTitle(id: self.groupId, title: title)
                
            }
        }
        
    }
    @objc func btnCrossTapped(sender:UIButton) {
        let user = participants[sender.tag]
        let alert = UIAlertController(title: "Remove user".localized, message: "Are you sure to remove this user?".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in

        }))
        alert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: { (nil) in

            let removeParticipant = RPC.PM_group_removeParticipant();
            removeParticipant.id = self.groupId;
            removeParticipant.userID = user.id;
            print(removeParticipant.userID)
            
            NetworkManager.shared.sendPacket(removeParticipant) { response, e in
                if (response != nil) {
                    
                    DispatchQueue.main.async {
                        let _ = self.participants.remove(at: sender.tag)
                        self.group.users.remove(at: sender.tag)
                        GroupDataManager.shared.updateGroup(groupObject: self.group)
                        self.tableViewParticipants.reloadData()
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - TableViewDelegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let data = participants[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupSettingContactsTableViewCell") as! GroupSettingContactsTableViewCell
        cell.configure(data: data)
        
        if data.id != creatorId && isCreator {
            cell.btnCross.addTarget(self, action:#selector(btnCrossTapped), for: .touchUpInside)
            cell.btnCross.tag = row
            cell.btnCross.isEnabled = true
            cell.cross.isHidden = false
        }
        return cell
    }
    
}
