import UIKit

class SettingsViewController : UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var borderConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        borderConstraint.constant = 0.5
        
        // Left bar button item added.
        let navigationItem = UINavigationItem()
        let leftButton = UIBarButtonItem(image: UIImage(named: "nav_bar_item_arrow_left"), style: .plain, target: self, action: #selector(onNavBarItemLeftClicked))
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.title = "Settings".localized
        navigationBar.items = [navigationItem]
    }
    
    // This Method calls when user clicked on the left bar button Iteam or back button.
    @objc func onNavBarItemLeftClicked() {
        dismiss(animated: true)
    }
}
