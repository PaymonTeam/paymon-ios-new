import UIKit

class SettingsTableView : UITableViewController {
    
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var notificationsTableViewCell: UITableViewCell!
    @IBOutlet weak var settingsAvatar: ObservableImageView!
    @IBOutlet weak var settingsName: UILabel!
    
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet var securityCell: UILabel!
    @IBOutlet var logOutCell: UIButton!
    
    @IBOutlet weak var aboutTheProgramCell: UILabel!
    
    @IBAction func onLogoutClicked(_ sender: Any) {
        
        User.clearConfig()
        NetworkManager.instance.reconnect()
        //        bookingCompleteAcknowledged()
        
    }
    
    // Changing the root view controller as user clicked on the logout button.
    func bookingCompleteAcknowledged(){
        
        dismiss(animated: true, completion: nil)
        
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            
            if let navController = topController.childViewControllers[0] as? UINavigationController{
                navController.popToRootViewController(animated: false)
                
                if let funnelController = navController.childViewControllers[0] as? SettingsViewController {
                    funnelController.removeFromParentViewController();
                    funnelController.view.removeFromSuperview();
                    
                    let revealController = self.storyboard?.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
                    
                    navController.addChildViewController(revealController)
                    navController.view.addSubview(revealController.view)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    // This method update the view when this view controller initialize.
    func updateView() {
        
        self.notificationsLabel.text! = "Notifications".localized
        self.securityCell.text! = "Security".localized
        self.aboutTheProgramCell.text! = "About the program".localized
        self.logOutCell.setTitle("Log out".localized, for: .normal)
        
        settingsAvatar.setPhoto(ownerID: User.currentUser!.id, photoID: User.currentUser!.photoID)
        settingsName.text! = Utils.formatUserName(User.currentUser!)
        
    }
}
