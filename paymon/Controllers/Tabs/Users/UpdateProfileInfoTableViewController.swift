import UIKit
import Foundation

class UpdateProfileInfoTableViewController : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cityInfo: UITextField!
    @IBOutlet weak var countryInfo: UITextField!
    @IBOutlet weak var bdayInfo: UITextField!
    @IBOutlet weak var emailInfo: UITextField!
    @IBOutlet weak var phoneInfo: UITextField!

    @IBOutlet weak var sexPicker: UISegmentedControl!
    @IBOutlet weak var surnameInfo: UITextField!
    @IBOutlet weak var nameInfo: UITextField!
    
    private var observerUpdateProfile : NSObjectProtocol!
    
    private var observerUpdateView : NSObjectProtocol!
    private var observerUpdateString : NSObjectProtocol!

    var cityString = ""
    var countryString = ""
    var bdayString = ""
    var emailString = ""
    var phoneString = ""
    var nameString = ""
    var surnameString = ""
    var sex: Int32 = 0

    let datePicker = UIDatePicker()
    static var needRemoveObservers = false

    @objc func endEditing() {
        self.view.endEditing(true)
    }

    func createDatePicker() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyy-MM-dd"
        let minDate = dateFormatter.date(from: "1917-01-01")!
        let maxDate = dateFormatter.date(from: "2017-01-01")!


        datePicker.datePickerMode = .date
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(datePickerDonePressed))
        toolbar.setItems([doneButton], animated: false)

        bdayInfo.inputAccessoryView = toolbar

        bdayInfo.inputView = datePicker


    }

    @objc func datePickerDonePressed() {

        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ja_JP")

        let date = dateFormatter.string(from: datePicker.date)

        bdayInfo.text = ""
        bdayInfo.text = date.replacingOccurrences(of: "/", with: "-")

        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //TODO: дописать return
        textField.resignFirstResponder()
        return (true)

    }

    @objc func textFieldDidChanged(_ textField : UITextField) {
        if (nameInfo.text != nameString || surnameInfo.text != surnameString
                || cityInfo.text != cityString || phoneInfo.text != phoneString
                || emailInfo.text != emailString || bdayInfo.text != bdayString
                || countryInfo.text != countryString
                || sexPicker.selectedSegmentIndex != sex) {

            print("true")
            NotificationCenter.default.post(name: .updateProfileInfoTrue, object: nil)

        } else {

            NotificationCenter.default.post(name: .updateProfileInfoFalse, object: nil)

        }
    }

    @objc func segmentControlChangeValue(_ segmentControl : UISegmentedControl) {
        if (nameInfo.text != nameString || surnameInfo.text != surnameString
                || cityInfo.text != cityString || phoneInfo.text != phoneString
                || emailInfo.text != emailString || bdayInfo.text != bdayString
                || countryInfo.text != countryString
                || sexPicker.selectedSegmentIndex != sex) {

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
        cityString = user.city ?? ""
        phoneString = String(user.phoneNumber)
        emailString = user.email ?? ""
        bdayString = user.birthdate ?? ""
        countryString = user.country ?? ""
        sex = user.gender! == 2 ? 1 : 0

    }

    func updateView () {
        
        guard let user = User.currentUser as RPC.UserObject? else {
            return
        }
        
        sexPicker.selectedSegmentIndex = user.gender! == 2 ? 1 : 0
        nameInfo.text = user.first_name ?? ""
        surnameInfo.text = user.last_name ?? ""
        cityInfo.text = user.city ?? ""
        phoneInfo.text = String(user.phoneNumber)
        emailInfo.text = user.email ?? ""
        bdayInfo.text = user.birthdate ?? ""
        countryInfo.text = user.country ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="yyyy-MM-dd"
        let date = dateFormatter.date(from: User.currentUser!.birthdate)!
        datePicker.date = date
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch (section) {
            case 0: return "Information about you".localized
            case 1: return ""
            case 2: return ""
            default: return "Information about you".localized
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateView()
        updateString()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        observerUpdateProfile = NotificationCenter.default.addObserver(forName: .updateProfile, object: nil, queue: nil ){ notification in

            UserManager.updateProfileInfo(name: self.nameInfo.text!, surname: self.surnameInfo.text!, email: self.emailInfo.text!, phone: self.phoneInfo.text!, city: self.cityInfo.text!, bday: self.bdayInfo.text!, country: self.countryInfo.text!, sex: self.sexPicker.selectedSegmentIndex, vc: self)
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

        self.cityInfo.delegate = self
        self.countryInfo.delegate = self
        self.bdayInfo.delegate = self
        self.emailInfo.delegate = self
        self.phoneInfo.delegate = self
        self.nameInfo.delegate = self
        self.surnameInfo.delegate = self

        self.cityInfo.placeholder = "City".localized
        self.countryInfo.placeholder = "Country".localized
        self.emailInfo.placeholder = "E-mail".localized
        self.phoneInfo.placeholder = "Phone number".localized
        self.nameInfo.placeholder = "Name".localized
        self.surnameInfo.placeholder = "Surname".localized

        self.sexPicker.setTitle("Male".localized, forSegmentAt: 0)
        self.sexPicker.setTitle("Female".localized, forSegmentAt: 1)

        createDatePicker()

        nameInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        surnameInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        cityInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        phoneInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        bdayInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingDidEnd)
        emailInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        countryInfo.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)


        sexPicker.addTarget(self, action: #selector(segmentControlChangeValue(_:)), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if UpdateProfileInfoTableViewController.needRemoveObservers {
            NotificationCenter.default.removeObserver(self)
        }
        
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to: self.tableView)
//        var contentOffset:CGPoint = self.tableView.contentOffset
//        contentOffset.y  = pointInTable.y
//        if let accessoryView = textField.inputAccessoryView {
//            contentOffset.y -= accessoryView.frame.size.height
//        }
//        self.tableView.contentOffset = contentOffset
//        return true;
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case nameInfo:
            return newLength <= 128
        case surnameInfo:
            return newLength <= 128
        case emailInfo:
            return newLength <= 128
        default: print("")
        }
        
        return true
    }


}
