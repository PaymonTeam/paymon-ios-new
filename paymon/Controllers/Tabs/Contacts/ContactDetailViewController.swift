//
//  ContactDetailViewController.swift
//  paymon
//
//  Created by SHUBHAM AGARWAL on 02/09/18.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactNumber: UILabel!
    
    // Data Coming from previous controller.
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Info"
        contactName.text = contact?.name ?? "N/A"
        contactNumber.text = contact?.phone ?? "N/A"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickInvitePaymon(_ sender: Any) {
    }
}
