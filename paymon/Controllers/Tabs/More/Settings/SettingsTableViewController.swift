import UIKit

class SettingsTableViewController : UITableViewController {
    
    @IBOutlet weak var notifications: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var wallet: UILabel!
    
    @IBOutlet weak var aboutApp: UILabel!
    @IBOutlet weak var security: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications.text = "Notifications".localized
        account.text = "Account".localized
        wallet.text = "Wallet".localized
        security.text = "Security".localized
        aboutApp.text = "About the application".localized
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
}
