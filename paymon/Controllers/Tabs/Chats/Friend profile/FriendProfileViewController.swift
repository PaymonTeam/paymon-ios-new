//
//  FriendProfileViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 18.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class FriendProfileViewController: PaymonViewController {

    @IBOutlet weak var wallets: UIButton!
    @IBOutlet weak var stackButtons: UIView!
    @IBOutlet weak var sendMessage: UIButton!
    @IBOutlet weak var login: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: ObservableImageView!
    @IBOutlet weak var headerView: UIView!
    
    var funcsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var id : Int32!
    var fromChat = false
    
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
    
    func loadWallets() {
        
        let getBtcWallet = RPC.PM_BTC_getWalletKey()
        getBtcWallet.uid = id
        let _ = NetworkManager.instance.sendPacket(getBtcWallet) { response, e in
            if response == nil {
                return
            } else {
                print("This user does not have BTC wallet")
            }
            
            guard let btcWallet = response as? RPC.PM_BTC_setWalletKey else {return}
            
            let bitcoin = UIAlertAction(title: "Bitcoin", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                guard let keysViewController = StoryBoard.bitcoin.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
                
                //TODO: Set private key here
                keysViewController.keyValue = btcWallet.walletKey
                
                self.present(keysViewController, animated: true, completion: nil)
            })
            
            self.funcsMenu.addAction(bitcoin)
        }
        
        let getEthWallet = RPC.PM_ETC_getWalletKey()
        getEthWallet.uid = id
        let _ = NetworkManager.instance.sendPacket(getEthWallet) { response, e in
            if response == nil {
                return
            } else {
                print("This user does not have ETH wallet")
            }
            
            guard let ethWallet = response as? RPC.PM_ETC_setWalletKey else {return}
            
            let ethereum = UIAlertAction(title: "Ethereum", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                guard let keysViewController = StoryBoard.bitcoin.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
                
                //TODO: Set private key here
                keysViewController.keyValue = ethWallet.walletKey
                
                self.present(keysViewController, animated: true, completion: nil)
            })
            
            self.funcsMenu.addAction(ethereum)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        self.funcsMenu.addAction(cancel)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setLayoutOptions()
        getUserInfo()
        loadWallets()
    }
    
    func getUserInfo() {
        let request = RPC.PM_getUserInfo()
        request.user_id = id
        
        let _ = NetworkManager.instance.sendPacket(request) { response, e in
            
            if response == nil {
                print("Error get user info")
                return
            }
            
            guard let user = response as? RPC.UserObject else {return}
            DispatchQueue.main.async {
                self.name.text = Utils.formatUserName(user)
                self.login.text = "@\(user.login!)"
                self.avatar.setPhoto(ownerID: user.id, photoID: user.photoID)
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
