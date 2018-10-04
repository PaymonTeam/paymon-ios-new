//
//  SettingAccountTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 02/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class SettingAccountTableViewController: UITableViewController {
    
    @IBOutlet weak var showEmailCell: UITableViewCell!
    let switchShowEmail = UISwitch()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutOptions()
        loadSettings()
        
    }
    
    func setLayoutOptions() {
        showEmailCell.textLabel!.text! = "Show email".localized
        switchShowEmail.onTintColor = UIColor.AppColor.Blue.primaryBlue

        showEmailCell.accessoryView = switchShowEmail

        
        switchShowEmail.addTarget(self, action: #selector(segmentControlChangeValue(_:)), for: .valueChanged)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0: return "Email".localized
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch (section) {
        case 0: return "Other users will be able to see your email address in your profile".localized
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }
    
    @objc func segmentControlChangeValue(_ segmentControl : UISegmentedControl) {
        if switchShowEmail.isOn == false {
            User.securityPasscodeValue = ""
            
//            User.saveSecuritySettings()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveSettings()
        
    }
    
    // Load the password protection setting from userDefaults.
    func loadSettings() {
        
        switchShowEmail.setOn(User.securityPasscode, animated: true)
        
    }
    
    // Save the changes made by user in the password protection setting.
    func saveSettings () {
        User.securityPasscode = switchShowEmail.isOn
        
        if (switchShowEmail.isOn == false) {
            User.securityPasscodeValue = ""
        }
        
//        User.saveSecuritySettings()
    }
}
