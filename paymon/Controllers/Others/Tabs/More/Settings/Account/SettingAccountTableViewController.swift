//
//  SettingAccountTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 02/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class SettingAccountTableViewController: UITableViewController {
    
    var canChange = true
    
    @IBOutlet weak var showEmailCell: UITableViewCell!
    @IBOutlet weak var timeFormatCell: UITableViewCell!
    let switchShowEmail = UISwitch()
    let switchTimeFormat = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutOptions()
        
    }
    
    func setLayoutOptions() {
        showEmailCell.textLabel!.text! = "Hide email address".localized
        timeFormatCell.textLabel!.text! = "24-Hour Time".localized

        switchShowEmail.onTintColor = UIColor.AppColor.Blue.primaryBlue
        switchTimeFormat.onTintColor = UIColor.AppColor.Blue.primaryBlue

        showEmailCell.accessoryView = switchShowEmail
        timeFormatCell.accessoryView = switchTimeFormat

        if User.currentUser != nil {
            switchShowEmail.setOn(User.currentUser.isEmailHidden, animated: false)
            switchTimeFormat.setOn(User.timeFormatIs24, animated: false)
        }
        
        switchShowEmail.addTarget(self, action: #selector(switchShowEmailChange(_:)), for: .valueChanged)
        switchTimeFormat.addTarget(self, action: #selector(switchTimeFormatChange(_:)), for: .valueChanged)

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0: return "Email".localized
        case 1: return "Time".localized

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
    
    @objc func switchShowEmailChange(_ segmentControl : UISegmentedControl) {
        let _ = MBProgressHUD.showAdded(to: self.view, animated: true)

        if canChange {
            canChange = false
            UserManager.shared.showEmail(isShow: switchShowEmail.isOn) { isDone in
                
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                self.canChange = isDone
                if isDone {
                    User.saveConfig()
                    DispatchQueue.main.async {
                        Utils.showSuccesHud(vc: self)
                    }
                } else {
                    _ = SimpleOkAlertController.init(title: "Show/Hide email".localized, message: "An error occurred during the update".localized, vc: self)
                }
            }
        }
    }
    
    @objc func switchTimeFormatChange(_ segmentControl : UISegmentedControl) {

        User.saveTimeFormat(is24: switchTimeFormat.isOn)
    }
}
