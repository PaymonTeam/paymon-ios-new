
import UIKit
import Foundation

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

class AboutProgramViewController : PaymonViewController {

    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setOptionLayout()

    }
    
    func setOptionLayout() {
        self.title = "About the application".localized
        self.versionLabel.text = ("Version ".localized + "\(UIApplication.appVersion!)"+"b")

        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
    }
}
