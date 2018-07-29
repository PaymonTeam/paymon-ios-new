import UIKit
import Foundation
import UserNotifications

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profileAvatar: ObservableImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileLogin: UILabel!
    
    @IBAction func settingsItemClick(_ sender: Any) {
        //        let settingsView = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        //        settingsView.modalPresentationStyle = .overCurrentContext
        //        present(settingsView, animated: true)
    }
    
    @IBAction func updateProfileClick(_ sender: Any) {
        guard let updateProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.updateProfileViewController) as! UpdateProfileViewController? else {return}
        
        self.present(updateProfileViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        DispatchQueue.main.async {
            
            self.profileAvatar.setPhoto(ownerID: user.id, photoID: user.photoID)
            self.profileName.text! = Utils.formatUserName(user)
            self.profileLogin.text = "@\(user.login!)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.topItem?.title = "Profile".localized
        
    }
    
}

