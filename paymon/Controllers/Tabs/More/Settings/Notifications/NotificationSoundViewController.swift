import UIKit

class NotificationSoundViewController: PaymonViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        self.title = "Sounds".localized
        
    }
}
