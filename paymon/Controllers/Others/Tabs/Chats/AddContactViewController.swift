

import UIKit
import Contacts
import ContactsUI

class Contact {
    var name: String?
    var email: String?
    var phone: String?
    init(name: String?, email: String?, phone: String?) {
        self.name = name ?? "N/A"
        self.email = email ?? "N/A"
        self.phone = phone ?? "N/A"
    }
}

class AddContactViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var newGroupView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    
    @IBOutlet weak var newGroup: UIButton!
    
    var cnContacts  = [CNContact]()
    
    var contacts = [Contact]()

    var outputDict = [String:[String]]()
    var filteredOutput = [String:[String]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        setLayoutOptions()
        
        searchBar.delegate = self
    }
    
    func setLayoutOptions() {
        searchBar.placeholder = "Search for contacts or users".localized
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.title = "New chat".localized
        newGroup.setTitle("New group".localized, for: .normal)
        newGroupView.layer.cornerRadius = newGroupView.frame.height/2
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.7)
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel?.textAlignment = .right

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClickback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredOutput = outputDict
            contactTableView.reloadData()
            return
        }
        
        filteredOutput = outputDict.filter({contact -> Bool in
            return contact.key.lowercased().contains(searchText.lowercased())
        })
        
        contactTableView.reloadData()
    }
    
    func getContacts() {
        let store = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            self.retrieveContactsWithStore(store: store)
            
        // This is the method we will create
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.retrieveContactsWithStore(store: store)
            }
        default:
            print("Not handled")
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        cnContacts = [CNContact]()
        
        
        request.sortOrder = CNContactSortOrder.userDefault
        
        let store = CNContactStore()
        
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stop) -> Void in
                self.cnContacts.append(contact)
                
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        for contact in cnContacts {
            let name = contact.givenName
            let email = String(contact.emailAddresses.first?.value ?? "N/A")
            let phone = contact.phoneNumbers.first?.value.stringValue
            let con = Contact(name: name, email: email, phone: phone)
            contacts.append(con)
        }
        
        for word in contacts {
            if let value = word.name?.isEmpty, !value {
                let initialLetter = word.name?.substring(toIndex: 1) .uppercased()
                if initialLetter != "" {
                    var letterArray = outputDict[initialLetter!] ?? [String]()
                    letterArray.append(word.name!)
                    outputDict[initialLetter!] = letterArray
                    filteredOutput = outputDict
                }
            }
        }
        
        DispatchQueue.main.async {
            self.contactTableView.reloadData()
        }
    }

    @IBAction func unWindCreateGroup(_ segue: UIStoryboardSegue) {
        
    }
}



extension AddContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredOutput.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let a = Array(filteredOutput.keys).sorted()
        return (filteredOutput[a[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = Array(filteredOutput.keys).sorted()
        let data = filteredOutput[a[indexPath.section]]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as? ContactTableViewCell else {
            fatalError("Unable to deque tableview cell")
        }
        cell.name.text = data?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let a = Array(filteredOutput.keys).sorted()
        return a[section]
    }
}

