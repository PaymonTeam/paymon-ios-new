import UIKit
import Foundation
import UserNotifications
import CoreStore

class ProfileViewController: PaymonViewController {
    
    @IBOutlet weak var profileAvatar: CircularImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileLogin: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBAction func updateProfileClick(_ sender: Any) {
        
        guard let updateProfile = StoryBoard.user.instantiateViewController(withIdentifier: VCIdentifier.updateProfileViewController) as? UpdateProfileViewController else {return}
        self.navigationController?.pushViewController(updateProfile, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        DispatchQueue.main.async {
            
            self.profileAvatar.loadPhoto(url: user.photoUrl.url)
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
        
        self.navigationItem.title = "Profile".localized

    }
    
}

