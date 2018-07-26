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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.topItem?.title = "Profile".localized
        
        if (User.currentUser != nil) {
            DispatchQueue.main.async {
                
//                print("owner id - \(User.currentUser!.id) \n photo id - \(User.currentUser!.photoID)")
                self.profileAvatar.setPhoto(ownerID: User.currentUser!.id, photoID: User.currentUser!.photoID)
                self.profileName.text! = Utils.formatUserName(User.currentUser!)
                self.profileLogin.text = "@\(User.currentUser!.login!)"
            }
        }

    }
    
    @IBAction func unWind(_ segue: UIStoryboardSegue) {
        
    }
}

