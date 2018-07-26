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
        nameString = User.currentUser?.first_name ?? ""
        surnameString = User.currentUser?.last_name ?? ""
        cityString = User.currentUser?.city ?? ""
        phoneString = String(User.currentUser!.phoneNumber)
        emailString = User.currentUser!.email ?? ""
        bdayString = User.currentUser!.birthdate ?? ""
        countryString = User.currentUser!.country ?? ""
        sex = User.currentUser!.gender! == 2 ? 1 : 0

    }

    func updateView () {
        
        sexPicker.selectedSegmentIndex = User.currentUser!.gender! == 2 ? 1 : 0
        nameInfo.text = User.currentUser?.first_name ?? ""
        surnameInfo.text = User.currentUser?.last_name ?? ""
        cityInfo.text = User.currentUser?.city ?? ""
        phoneInfo.text = String(User.currentUser!.phoneNumber)
        emailInfo.text = User.currentUser?.email ?? ""
        bdayInfo.text = User.currentUser?.birthdate ?? ""
        countryInfo.text = User.currentUser?.country ?? ""
        
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

        updateView()
        updateString()
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
            NotificationCenter.default.removeObserver(observerUpdateProfile)
            NotificationCenter.default.removeObserver(observerUpdateView)
            NotificationCenter.default.removeObserver(observerUpdateString)
        }
        
    }

}
