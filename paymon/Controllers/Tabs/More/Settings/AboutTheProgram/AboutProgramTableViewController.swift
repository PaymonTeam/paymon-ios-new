//
//  AboutProgramTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 02/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class AboutProgramTableViewController: UITableViewController {

    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    
    @IBOutlet weak var licenseCell: UITableViewCell!
    @IBOutlet weak var evaluationCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        privacyCell.textLabel?.text = "Privacy policy".localized
        termsCell.textLabel?.text = "Terms of use".localized
        licenseCell.textLabel?.text = "Licenses".localized
        evaluationCell.textLabel?.text = "Rate app".localized
        
    }
}
