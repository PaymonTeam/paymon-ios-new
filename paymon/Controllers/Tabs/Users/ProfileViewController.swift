import UIKit
import Foundation
import UserNotifications

class ProfileViewController: PaymonViewController {
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profileAvatar: ObservableImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileLogin: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBAction func settingsItemClick(_ sender: Any) {
        //        let settingsView = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        //        settingsView.modalPresentationStyle = .overCurrentContext
        //        present(settingsView, animated: true)
        
        User.clearConfig()
        self.dismiss(animated: true, completion: nil)
        
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
        
        setLayoutOptions()
    }
    
    func setLayoutOptions(){
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.headerView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width
        
        self.headerView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.headerView.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Profile".localized

    }
    
}

