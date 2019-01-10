//
//  FriendProfileViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 18.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import MBProgressHUD
import DeckTransition

class FriendProfileViewController: PaymonViewController {

    @IBOutlet weak var wallets: UIButton!
    @IBOutlet weak var stackButtons: UIView!
    @IBOutlet weak var sendMessage: UIButton!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var viewForTable: UserInfoTableInfoUIView!
    @IBOutlet weak var avatar: CircularImageView!
    @IBOutlet weak var headerView: UIView!
    
    var funcsMenu = UIAlertController(title: "Wallets".localized, message: "Here you can find out the public keys of this user".localized, preferredStyle: .actionSheet)
    
    var id : Int32!
    var fromChat = false
    var friend : RPC.PM_userFull!
    
    func hideMenu(isHidden : Bool) {
        if isHidden {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        headerView.isHidden = isHidden
        stackButtons.isHidden = isHidden
        viewForTable.isHidden = isHidden
    }
    
    @IBAction func sendMessageClick(_ sender: Any) {
        if fromChat {
            self.navigationController?.popViewController(animated: true)
        } else {
            let chatViewController = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as! ChatViewController
            chatViewController.setValue(name.text!, forKey: "title")
            chatViewController.isGroup = false
            
            chatViewController.chatID = id
            
            self.navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
    
    
    @IBAction func walletsClick(_ sender: Any) {
        self.present(funcsMenu, animated: true, completion: nil)
    }
    
    func setWallets() {
        
        if !friend.btcAddress.isEmpty {
            let bitcoin = UIAlertAction(title: "Bitcoin", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                guard let keysViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
                
                keysViewController.keyValue = self.friend.btcAddress
                keysViewController.currency = Money.btc
                
                let transitionDelegate = DeckTransitioningDelegate()
                keysViewController.transitioningDelegate = transitionDelegate
                keysViewController.modalPresentationStyle = .custom
                self.present(keysViewController, animated: true, completion: nil)
                
            })
            
            self.funcsMenu.addAction(bitcoin)
        }
        
        if !friend.ethAddress.isEmpty {
            let ethereum = UIAlertAction(title: "Ethereum", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                guard let keysViewController = StoryBoard.money.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
                
                keysViewController.keyValue = self.friend.ethAddress
                keysViewController.currency = Money.eth
                
                let transitionDelegate = DeckTransitioningDelegate()
                keysViewController.transitioningDelegate = transitionDelegate
                keysViewController.modalPresentationStyle = .custom
                
                self.present(keysViewController, animated: true, completion: nil)
            })
            
            self.funcsMenu.addAction(ethereum)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        self.funcsMenu.addAction(cancel)
        self.hideMenu(isHidden: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
        hideMenu(isHidden: true)
        setLayoutOptions()
        getUserInfo()
    }
    
    func getUserInfo() {

        let request = RPC.PM_getUserInfo(user_id: id)
        
        let _ = NetworkManager.shared.sendPacket(request) { response, e in
            
            if response == nil {
                print("Error get user info")
                return
            }
            
            guard let user = response as? RPC.PM_userFull else {return}
            self.friend = user
            DispatchQueue.main.async {
                self.name.text = Utils.formatUserName(user)
                self.login.text = "@\(user.login!)"
                self.avatar.loadPhoto(url: user.photoUrl.url)
                self.setWallets()
            }
            NotificationCenter.default.post(name: .setFriendProfileInfo, object: user)
        }
    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.headerView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width
        
        self.headerView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.headerView.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        
        self.navigationItem.title = "Profile".localized
        self.sendMessage.setTitle("Send message".localized, for: .normal)
        self.wallets.setTitle("Wallets".localized, for: .normal)
        self.stackButtons.layer.masksToBounds = true
        self.stackButtons.layer.cornerRadius = 30
    }
}
