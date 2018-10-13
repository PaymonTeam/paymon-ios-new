import UIKit
import Foundation

class UpdateProfileInfoTableViewController : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var surnameInfo: UITextField!
    @IBOutlet weak var nameInfo: UITextField!
    
    private var observerUpdateProfile : NSObjectProtocol!
    
    private var observerUpdateView : NSObjectProtocol!
    private var observerUpdateString : NSObjectProtocol!

    var nameString = ""
    var surnameString = ""
    
    static var needRemoveObservers = true
    var newCountry : String!

    
    @objc func endEditing() {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //TODO: дописать return
        textField.resignFirstResponder()
        return true

    }

    @objc func textFieldDidChanged(_ textField : UITextField) {
        
        if (nameInfo.text != nameString || surnameInfo.text != surnameString) {

            NotificationCenter.default.post(name: .updateProfileInfoTrue, object: nil)

        } else {

            NotificationCenter.default.post(name: .updateProfileInfoFalse, object: nil)

        }
    }

    @objc func segmentControlChangeValue(_ segmentControl : UISegmentedControl) {
        if (nameInfo.text != nameString || surnameInfo.text != surnameString) {

            NotificationCenter.default.post(name: .updateProfileInfoTrue, object: nil)

        } else {
            NotificationCenter.default.post(name: .updateProfileInfoFalse, object: nil)

        }
    }
    
    func updateString() {
        
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        
        nameString = user.first_name ?? ""
        surnameString = user.last_name ?? ""
    }

    func updateView () {
        
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        
        DispatchQueue.main.async {
            self.nameInfo.text = user.first_name ?? ""
            self.surnameInfo.text = user.last_name ?? ""

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UpdateProfileInfoTableViewController.needRemoveObservers = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerUpdateProfile = NotificationCenter.default.addObserver(forName: .updateProfile, object: nil, queue: nil ){ notification in

            UserManager.updateProfileInfo(name: self.nameInfo.text!, surname: self.surnameInfo.text!, vc: self.parent!)
        }
        
        observerUpdateView = NotificationCenter.default.addObserver(forName: .updateView, object: nil, queue: nil ){ notification in
            self.updateView()
        }
        
        observerUpdateString = NotificationCenter.default.addObserver(forName: .updateString, object: nil, queue: nil ){ notification in
            self.updateString()
        }

        let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)

        self.nameInfo.delegate = self
        self.surnameInfo.delegate = self
        
        self.nameInfo.placeholder = "Name".localized
        self.surnameInfo.placeholder = "Surname".localized

        nameInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        surnameInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)


        updateString()
        updateView()
        
    }
    
    @objc func postNotificationForShowCountryPicker() {
        NotificationCenter.default.post(name: .showCountryPicker, object: nil)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if UpdateProfileInfoTableViewController.needRemoveObservers {
            NotificationCenter.default.removeObserver(observerUpdateProfile)
            NotificationCenter.default.removeObserver(observerUpdateView)

            NotificationCenter.default.removeObserver(observerUpdateString)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case nameInfo:
            return newLength <= 128
        case surnameInfo:
            return newLength <= 128
        default: break
        }
        
        return true
    }


}
