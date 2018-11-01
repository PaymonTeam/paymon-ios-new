import UIKit

class SettingsTableViewController : UITableViewController {
    
    @IBOutlet weak var notifications: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var wallet: UILabel!
    
    @IBOutlet weak var aboutApp: UILabel!
    @IBOutlet weak var security: UILabel!
    
    @IBOutlet weak var logOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications.text = "Notifications".localized
        account.text = "Account".localized
        wallet.text = "Wallet".localized
        security.text = "Security".localized
        aboutApp.text = "About the application".localized
        logOut.setTitle("Log out".localized, for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    @IBAction func logOutClick(_ sender: Any) {
        let logOutMenu = UIAlertController(title: "Logged in as ".localized+"\(Utils.formatUserName(User.currentUser))", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let logOut = UIAlertAction(title: "Log out".localized, style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let startViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.mainNavigationController)
            
            User.clearConfig()
            MessageManager.dispose()
            NetworkManager.shared.reconnect()
            appDelegate.window?.rootViewController = startViewController
        })
        
        logOutMenu.addAction(cancel)
        logOutMenu.addAction(logOut)
        
        self.present(logOutMenu, animated: true, completion: nil)
    }
}
