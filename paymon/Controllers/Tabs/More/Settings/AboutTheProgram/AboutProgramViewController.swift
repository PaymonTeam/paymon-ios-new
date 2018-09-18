
import UIKit
import Foundation

class AboutProgramViewController : PaymonViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!

    var dict : NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Paymon for iOS".localized
        self.view.addUIViewBackground(name: "MainBackground")
        
        // Left bar button item added.
        let navigationItem = UINavigationItem()
        let leftButton = UIBarButtonItem(image: UIImage(named: "nav_bar_item_arrow_left"), style: .plain, target: self, action: #selector(onNavBarItemLeftClicked))
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.title = "About the program".localized
        navigationBar.items = [navigationItem]

        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        dict = NSDictionary(contentsOfFile: path!)

        // Getting version number from plist.
        if let dictInfo = dict {
            versionLabel.text = ("version ".localized + "\(dictInfo["CFBundleShortVersionString"]!)"+"b")
        }

    }
    
    // This Method calls when user clicked on the left bar button Iteam or back button.
    @objc func onNavBarItemLeftClicked() {
        dismiss(animated: true)

    }
}
