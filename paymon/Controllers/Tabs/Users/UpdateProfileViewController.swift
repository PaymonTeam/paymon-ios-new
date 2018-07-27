import UIKit
import Foundation

class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var updateItem: UIBarButtonItem!
    @IBOutlet weak var changePhoto: UIButton!
    @IBOutlet weak var avatar: ObservableImageView!

    private var observerUpdateTrue : NSObjectProtocol!
    private var observerUpdateFalse : NSObjectProtocol!
    
    var needRemoveObservers = true
    
    @IBAction func arrowBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func addObservers() {
            observerUpdateTrue = NotificationCenter.default.addObserver(forName: .updateProfileInfoTrue, object: nil, queue: nil ){ notification in
                print("change!")
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

        changePhoto.setTitle("Change photo".localized, for: .normal)
        
        if let user = User.currentUser {
            avatar.setPhoto(ownerID: user.id, photoID: user.photoID)
        }
        self.updateItem.isEnabled = false

        navigationBar.topItem?.title = "Update Profile".localized

    }
    
    @IBAction func changePhotoClick(_ sender: Any) {
        needRemoveObservers = false
        UpdateProfileInfoTableViewController.needRemoveObservers = false

        let cardPicker = UIImagePickerController()
        cardPicker.allowsEditing = true
        cardPicker.delegate = self
        cardPicker.sourceType = .photoLibrary
        present(cardPicker, animated: true)
    }

    @IBAction func updateItemClick(_ sender: Any) {
        self.view.endEditing(true)
        
        updateItem.isEnabled = false
        NotificationCenter.default.post(name: .updateProfile, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        if needRemoveObservers {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        needRemoveObservers = true
        
        UserManager.updateAvatar(info: info, avatarView: avatar, vc: self)
    }
    
    
}
