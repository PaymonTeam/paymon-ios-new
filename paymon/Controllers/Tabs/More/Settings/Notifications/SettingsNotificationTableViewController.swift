

import UIKit

class SettingsNotificationTableViewController: UITableViewController {
    
    @IBOutlet weak var transactionsCell: UITableViewCell!
    @IBOutlet weak var vibrationCell: UITableViewCell!
    @IBOutlet weak var disturbCell: UITableViewCell!
    @IBOutlet weak var soundCell: UITableViewCell!
    
    let switchTransactions = UISwitch()
    let switchVibration = UISwitch()
    let switchWorry = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        
        loadSettings()
        
    }
    
    func setLayoutOptions() {
        transactionsCell.textLabel!.text! = "Transactions".localized
        vibrationCell.textLabel!.text! = "Vibration".localized
        soundCell.textLabel!.text! = "Sound".localized
        disturbCell.textLabel!.text! = "Do not disturb".localized
        
        switchTransactions.onTintColor = UIColor.AppColor.Blue.primaryBlue
        switchVibration.onTintColor = UIColor.AppColor.Blue.primaryBlue
        switchWorry.onTintColor = UIColor.AppColor.Blue.primaryBlue
        
        transactionsCell.accessoryView = switchTransactions
        vibrationCell.accessoryView = switchVibration
        disturbCell.accessoryView = switchWorry
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0: return "Messeges".localized
        case 1: return "Other".localized
        default: return "Other".localized
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveSettings()
        
    }
    
    // Load all the notification settings of user.
    func loadSettings() {
        switchWorry.setOn(User.notificationWorry, animated: true)
        switchVibration.setOn(User.notificationVibration, animated: true)
        switchTransactions.setOn(User.notificationTransactions, animated: true)
    }
    
    // Save all the changes, user made in the notification settings.
    func saveSettings () {
        User.notificationWorry = switchWorry.isOn
        User.notificationVibration = switchVibration.isOn
        User.notificationTransactions = switchTransactions.isOn
        
//        User.saveNotificationSettings()
    }
}
