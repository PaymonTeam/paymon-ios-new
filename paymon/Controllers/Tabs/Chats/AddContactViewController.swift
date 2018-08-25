

import UIKit
import Contacts
import ContactsUI

class Contact {
    @objc var name: String?
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
    
    var cnContacts  = [CNContact]()
    
    var contacts = [Contact]()
    let collation = UILocalizedIndexedCollation.current()
    var contactsWithSections = [[Contact]]()
    var sectionTitles = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContacts()
        searchBar.backgroundImage = UIImage()
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
    
    func retrieveContactsWithStore(store: CNContactStore)
    {
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
        
        //Create sections of contacts using collation object
        let (arrayContacts, arrayTitles) = collation.partitionObjects(array: self.contacts, collationStringSelector: #selector(getter: Contact.name))
        self.contactsWithSections = arrayContacts as! [[Contact]]
        self.sectionTitles = arrayTitles
        
        DispatchQueue.main.async {
            self.contactTableView.reloadData()
        }
    }
    
}

extension AddContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsWithSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactCell", for: indexPath)
        if let lbl = cell.viewWithTag(111) as? UILabel {
            lbl.text = contactsWithSections[indexPath.section][indexPath.row].name! as String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension UILocalizedIndexedCollation {
    
    //func for partition array in sections
    func partitionObjects(array:[AnyObject], collationStringSelector:Selector) -> ([AnyObject], [String]) {
        var unsortedSections = [[AnyObject]]()
        //1. Create a array to hold the data for each section
        for _ in self.sectionTitles {
            unsortedSections.append([]) //appending an empty array
        }
        //2. Put each objects into a section
        for item in array {
            let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
            unsortedSections[index].append(item)
        }
        //3. sorting the array of each sections
        var sectionTitles = [String]()
        var sections = [AnyObject]()
        for index in 0 ..< unsortedSections.count { if unsortedSections[index].count > 0 {
            sectionTitles.append(self.sectionTitles[index])
            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            }
        }
        return (sections, sectionTitles)
    }
}
