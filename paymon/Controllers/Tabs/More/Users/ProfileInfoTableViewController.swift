import UIKit
import Foundation

class ProfileInfoTableViewController : UITableViewController {
    
    @IBOutlet weak var emailInfo: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateView()
    }
    
    func updateView() {
        
        guard let user = User.currentUser else {
            return
        }
        
        DispatchQueue.main.async {
            
            if (user.email != nil) {
                self.emailInfo.text = user.email
            } else {
                self.emailInfo.text = "Is hidden".localized
            }
            
        }
    }
}


