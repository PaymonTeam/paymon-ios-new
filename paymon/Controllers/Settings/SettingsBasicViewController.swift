import UIKit

class SettingsBasicViewController : UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Left bar button item added.
        let navigationItem = UINavigationItem()
        let leftButton = UIBarButtonItem(image: UIImage(named: "nav_bar_item_arrow_left"), style: .plain, target: self, action: #selector(onNavBarItemLeftClicked))
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.title = "Basic"
        navigationBar.items = [navigationItem]

    }
    
    // This Method calls when user clicked on the left bar button Iteam or back button.
    @objc func onNavBarItemLeftClicked() {
        
        dismiss(animated: true)
        
    }
}
