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
        
        print(self.tableView.frame.height)

    }
    
    func updateView() {
        
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        
        DispatchQueue.main.async {
            
            self.cityInfo.text = !user.city.isEmpty ? user.city  : "Not choosen".localized
            self.phoneInfo.text = user.phoneNumber != 0 ? String(user.phoneNumber) : "Not choosen".localized
            self.emailInfo.text = !user.email.isEmpty ? user.email : "Not choosen".localized
            self.bdayInfo.text = !user.birthdate.isEmpty ? user.birthdate : "Not choosen".localized
            self.countryInfo.text = !user.country.isEmpty ? user.country : "Not choosen".localized
            
        }
    }
}


