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
    
    private var setFriendProfileInfo: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setFriendProfileInfo = NotificationCenter.default.addObserver(forName: .setFriendProfileInfo, object: nil, queue: OperationQueue.main) {
            notification in
            
            if let user = notification.object as? RPC.PM_userFull {
                DispatchQueue.main.async {
                    if user.email != nil {
                        self.email.text = user.email
                    } else {
                        self.email.text = "Is hidden".localized
                    }
                }
            } else if let user = notification.object as? UserData {
                DispatchQueue.main.async {
                    if user.email != nil {
                        self.email.text = user.email
                    } else {
                        self.email.text = "Is hidden".localized
                    }
                }
            }

        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(setFriendProfileInfo)
    }
}
