//
//  SettingsSecurityTableViewController.swift
//  paymon
//
//  Created by maks on 30.09.17.
//  Copyright © 2017 Paymon. All rights reserved.
//

import UIKit

class SettingsSecurityTableViewController: UITableViewController {
    
    
    @IBOutlet weak var passwordProtectCell: UITableViewCell!
    let switchPasswordProtect = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutOptions()
        loadSettings()
        
    }
    
    func setLayoutOptions() {
        passwordProtectCell.textLabel!.text! = "Password protect".localized
        
        switchPasswordProtect.onTintColor = UIColor.AppColor.Blue.primaryBlue

        passwordProtectCell.accessoryView = switchPasswordProtect
        
        switchPasswordProtect.addTarget(self, action: #selector(segmentControlChangeValue(_:)), for: .valueChanged)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0: return "Protect".localized
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch (section) {
        case 0: return "You can protect your application with a digital password".localized
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }
    
    @objc func segmentControlChangeValue(_ segmentControl : UISegmentedControl) {
        if switchPasswordProtect.isOn == false {
            User.securityPasswordProtectedString = ""
            
            User.saveSecuritySettings()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveSettings()
        
    }
    
    // Load the password protection setting from userDefaults.
    func loadSettings() {
        
        switchPasswordProtect.setOn(User.securitySwitchPasswordProtected, animated: true)
        
    }
    
    // Save the changes made by user in the password protection setting.
    func saveSettings () {
        User.securitySwitchPasswordProtected = switchPasswordProtect.isOn
        
        if (switchPasswordProtect.isOn == false) {
            User.securityPasswordProtectedString = ""
        }
        
        User.saveSecuritySettings()
    }
}
