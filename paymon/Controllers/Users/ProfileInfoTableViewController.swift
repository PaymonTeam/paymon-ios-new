import UIKit
import Foundation

class ProfileInfoTableViewController : UITableViewController {
    
    @IBOutlet weak var countryInfo: UILabel!
    @IBOutlet weak var emailInfo: UILabel!
    @IBOutlet weak var phoneInfo: UILabel!
    @IBOutlet weak var cityInfo: UILabel!
    @IBOutlet weak var bdayInfo: UILabel!
    
    override func viewDidLoad() {
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
        DispatchQueue.main.async {
            if (User.currentUser!.city != nil && !User.currentUser!.city.isEmpty) {
                self.cityInfo.text = User.currentUser!.city
            } else {
                self.cityInfo.text = "Not choosen".localized
            }
            
            if (User.currentUser!.phoneNumber != nil && User.currentUser!.phoneNumber != 0) {
                self.phoneInfo.text = String(User.currentUser!.phoneNumber)
            } else {
                self.phoneInfo.text = "Not choosen".localized
            }
            if (User.currentUser!.email != nil && !User.currentUser!.email.isEmpty) {
                self.emailInfo.text = User.currentUser!.email
            } else {
                self.emailInfo.text = "Not choosen".localized
            }
            if (User.currentUser!.birthdate != nil && !User.currentUser!.birthdate.isEmpty) {
                self.bdayInfo.text = User.currentUser!.birthdate
            } else {
                self.bdayInfo.text = "Not choosen".localized
            }
            if (User.currentUser!.country != nil && !User.currentUser!.country.isEmpty) {
                self.countryInfo.text = User.currentUser!.country
            } else {
                self.countryInfo.text = "Not choosen".localized
            }
        }
    }
}


