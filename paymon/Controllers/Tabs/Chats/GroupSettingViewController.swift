//
//  GroupSettingViewController.swift
//  paymon
//
//  Created by infoobjects on 5/26/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import UIKit
import MBProgressHUD


class GroupSettingContactsTableViewCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: ObservableImageView!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var cross: UIImageView!
}

class GroupSettingViewController: PaymonViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var groupTitleHint: UILabel!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var groupImage: ObservableImageView!
    @IBOutlet weak var tableViewParticipants: UITableView!
    @IBOutlet weak var addParticipants: UIButton!
    @IBOutlet weak var groupTitle: UITextField!

    var users:[RPC.UserObject] = []
    var chatID: Int32!
    var participants = SharedArray<RPC.UserObject>()
    var isCreator:Bool = false
    var creatorID:Int32!
    var group:RPC.Group!
    var newGroupTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        participants = MessageManager.instance.groupsUsers.value(forKey: chatID)!
        
        group = MessageManager.instance.groups[chatID]!
        groupTitle.text = group.title
        creatorID = group.creatorID;
        isCreator = creatorID == User.currentUser?.id
        
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
        
        default: print("")
        }
        
        return true
    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        groupTitle.layer.cornerRadius = groupTitle.frame.height/2
        addView.layer.cornerRadius = addView.frame.height/2
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.groupTitle.frame.height))

        groupTitle.leftView = paddingView
        groupTitle.leftViewMode = UITextFieldViewMode.always
        
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
        createGroupViewController.chatID = chatID
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

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage, let currentUser = User.currentUser {
            guard let photo = MediaManager.instance.savePhoto(image: image, user: currentUser) else {
                return
            }
            guard let photoFile = MediaManager.instance.getFile(ownerID: photo.user_id, fileID: photo.id) else {
                return
            }
            print("file saved \(photoFile)")
            let packet = RPC.PM_group_setPhoto()
            packet.photo = photo
            packet.id = chatID
            let oldPhotoID = group.photo.id!
            let photoID = photo.id!
            groupImage.image = image
            ObservableMediaManager.instance.postPhotoUpdateIDNotification(oldPhotoID: oldPhotoID, newPhotoID: photoID)
            
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            NetworkManager.instance.sendPacket(packet) { packet, error in
                
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                if (packet is RPC.PM_boolTrue) {
                    Utils.stageQueue.run {
                        PMFileManager.instance.startUploading(photo: photo, onFinished: {
                            print("File has uploaded")
                            
                        }, onError: { code in
                            print("file upload failed \(code)")
                            
                        }, onProgress: { p in
                        })
                    }
                } else {
                    
                    PMFileManager.instance.cancelFileUpload(fileID: photoID);
                }
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let chatVC = viewController as? ChatViewController else {return}
        
        if !newGroupTitle.isEmpty {
            chatVC.chatTitle.text = newGroupTitle
        }
        
        var text = "Participants: ".localized
        text.append("\(participants.count)")
        
        chatVC.chatSubtitle.text = text
        
    }

    @IBAction func btnDoneTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.done.isEnabled = false
        
        let _ = MBProgressHUD.showAdded(to: self.view, animated: true)

        let setSettings = RPC.PM_group_setSettings()
        setSettings.id = chatID;
        setSettings.title = groupTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        newGroupTitle = groupTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("new group title: \(newGroupTitle)")
        NetworkManager.instance.sendPacket(setSettings) { response, e in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }

            let manager = MessageManager.instance
            if (response != nil) {
                DispatchQueue.main.async {
                    manager.groups[self.chatID]?.title = self.groupTitle.text!
                    Utils.showSuccesHud(vc: self)
                }
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
            removeParticipant.id = self.chatID;
            removeParticipant.userID = user.id;
            
            NetworkManager.instance.sendPacket(removeParticipant) { response, e in
                if (response != nil) {
                    
                    DispatchQueue.main.async {
                        self.participants.remove(at: sender.tag)

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
        cell.name.text = Utils.formatUserName(data)
        cell.photo.setPhoto(ownerID: data.id, photoID: data.photoID)
        
        if data.id != creatorID && isCreator {
            
            cell.btnCross.addTarget(self, action:#selector(btnCrossTapped), for: .touchUpInside)
            cell.btnCross.tag = row
            cell.btnCross.isEnabled = true
            cell.cross.isHidden = false
        }
        return cell
    }
    
}
