import UIKit
import Foundation
import MBProgressHUD

class UpdateProfileViewController: PaymonViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var updateItem: UIBarButtonItem!
    @IBOutlet weak var changePhoto: UIButton!
    @IBOutlet weak var avatar: CircularImageView!

    private var observerUpdateTrue : NSObjectProtocol!
    private var observerUpdateFalse : NSObjectProtocol!

    @IBOutlet weak var headerView: UIView!
    var needRemoveObservers = true
    
    func addObservers() {
            observerUpdateTrue = NotificationCenter.default.addObserver(forName: .updateProfileInfoTrue, object: nil, queue: nil ){ notification in
                DispatchQueue.main.async {
                    self.updateItem.isEnabled = true
                }
            }
            
            observerUpdateFalse = NotificationCenter.default.addObserver(forName: .updateProfileInfoFalse, object: nil, queue: nil ){ notification in
                DispatchQueue.main.async {
                    self.updateItem.isEnabled = false
            }
        }
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()

        setLayoutOptions()
        
        if let user = User.currentUser {
            avatar.loadPhoto(url: user.photoUrl.url)
        }
        self.updateItem.isEnabled = false

    }
    
    func setLayoutOptions(){
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.headerView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width
        
        self.headerView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.headerView.frame.height), topColor: UIColor.white.cgColor, bottomColor: UIColor.AppColor.Blue.primaryBlueUltraLight.cgColor)
        
        self.title = "Update Profile".localized
        changePhoto.setTitle("Change photo".localized, for: .normal)

    }
    
    @IBAction func changePhotoClick(_ sender: Any) {
        needRemoveObservers = false
        UpdateProfileInfoTableViewController.needRemoveObservers = false

        let photoPicker = UIImagePickerController()
        photoPicker.allowsEditing = true
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        
        present(photoPicker, animated: true)
    }

    @IBAction func updateItemClick(_ sender: Any) {
        self.view.endEditing(true)
        
        updateItem.isEnabled = false
        NotificationCenter.default.post(name: .updateProfile, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        if needRemoveObservers {
            NotificationCenter.default.removeObserver(observerUpdateTrue)
            NotificationCenter.default.removeObserver(observerUpdateFalse)

        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        DispatchQueue.main.async {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        UserManager.shared.updateAvatar(info: info) { isUpdated, image, error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            if isUpdated {
                DispatchQueue.main.async {
                    Utils.showSuccesHud(vc: self)
                    self.avatar.image = image
                }
                
            } else {
                if error == 0 {
                    _ = SimpleOkAlertController.init(title: "Upload photo failed".localized, message: "The minimum width of the photo can be 256 points".localized, vc: self)
                } else if error == 1 {
                    print("file upload failed")
                    DispatchQueue.main.async {
                        _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: self)
                    }
                } else {
                    _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: self)
                    PMFileManager.shared.cancelFileUpload(fileID: Int64(User.currentUser.id));
                }
            }
        }
        
        needRemoveObservers = true
    }
}
