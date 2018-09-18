//
//  FriendProfileTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 18.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class FriendProfileTableViewController: UITableViewController {

    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var bday: UILabel!
    
    private var setFriendProfileInfo: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setFriendProfileInfo = NotificationCenter.default.addObserver(forName: .setFriendProfileInfo, object: nil, queue: OperationQueue.main) {
            notification in
            
            if let user = notification.object as? RPC.UserObject {
                DispatchQueue.main.async {
                    self.email.text = user.email
                    self.phone.text = String(user.phoneNumber)
                    self.bday.text = user.birthdate
                }
            }

        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(setFriendProfileInfo)
    }
}
