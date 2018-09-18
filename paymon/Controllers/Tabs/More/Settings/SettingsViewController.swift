import UIKit

class SettingsViewController : PaymonViewController {

    @IBOutlet weak var borderConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings".localized
        
    }
}
