import UIKit

class SettingsSecurityViewController : PaymonViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Security".localized
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
    }
}
