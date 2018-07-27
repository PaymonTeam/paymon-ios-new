import UIKit
import Foundation

class ProfileInfoTableViewController : UITableViewController {
    
    @IBOutlet weak var countryInfo: UILabel!
    @IBOutlet weak var emailInfo: UILabel!
    @IBOutlet weak var phoneInfo: UILabel!
    @IBOutlet weak var cityInfo: UILabel!
    @IBOutlet weak var bdayInfo: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateView()

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch (section) {
        case 0: return "Contact information".localized
        case 1: return "Personal information".localized
        default: return "Personal information".localized
        }
    }

    func updateView() {
        
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        
        DispatchQueue.main.async {
                        
            self.cityInfo.text = user.city ?? "Not choosen".localized
            self.phoneInfo.text = String(user.phoneNumber)
            self.emailInfo.text = user.email ?? "Not choosen".localized
            self.bdayInfo.text = user.birthdate ?? "Not choosen".localized
            self.countryInfo.text = user.country ?? "Not choosen".localized
            
        }
    }
}


