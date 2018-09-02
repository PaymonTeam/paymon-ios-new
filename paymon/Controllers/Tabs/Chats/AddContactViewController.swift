

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

class AddContactViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var newGroupOrInviteMeButton: UIButton!
    
    var cnContacts  = [CNContact]()
    
    var contacts = [Contact]()

    var outputDict=[String:[String]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        searchBar.backgroundImage = UIImage()
        searchBar.textField?.textColor = UIColor.black
        searchBar.textField?.backgroundColor = UIColor(red: 215/225.0, green: 215/225.0, blue: 215/225.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClickback(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
                    outputDict[initialLetter!]=letterArray
                }
            }
        }
        
        DispatchQueue.main.async {
            self.contactTableView.reloadData()
        }
    }
    
    @IBAction func onClickNewGroup(_ sender: Any) {
        let groupView = storyboard?.instantiateViewController(withIdentifier: "CreateGroupViewController") as! CreateGroupViewController
        present(groupView, animated: false, completion: nil)
    }
}

extension AddContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return outputDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let a = Array(outputDict.keys).sorted()
        return (outputDict[a[section]]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = Array(outputDict.keys).sorted()
        let data = outputDict[a[indexPath.section]]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as? ContactTableViewCell else {
            fatalError("Unable to deque tableview cell")
            
        }
        cell.name.text = data?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let a = Array(outputDict.keys).sorted()
        return a[section]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

