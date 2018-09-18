import UIKit
import Contacts
import ContactsUI

class ContactsTableViewCell : UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: ObservableImageView!
}

extension UISearchBar {
    public var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }
    
    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}

class ContactsViewController : UITableViewController, UISearchBarDelegate {
    let timerQueue = Queue()
    var searchTimer:PMTimer!
    var searchData:[RPC.UserObject] = []
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        
        searchTimer = PMTimer(timeout: 0, repeat: false, completionFunction: {
            DispatchQueue.main.async {
                self.onSearch(self.searchBar.text ?? "")
            }
        }, queue:timerQueue.nativeQueue())
    }
    
    func createSearchBar() {
        tableView.dataSource = self
        searchBar.placeholder = "Enter username or login".localized
        searchBar.delegate = self
        searchBar.isLoading = false
        searchBar.backgroundImage = UIImage()
        searchBar.textField?.textColor = UIColor.black
        searchBar.textField?.backgroundColor = UIColor(red: 215/225.0, green: 215/225.0, blue: 215/225.0, alpha: 1.0)
        
    }
    
    //MARK: - TableView Delegate Methods.
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let data = searchData[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell") as! ContactsTableViewCell
        cell.name.text = Utils.formatUserName(data)
        cell.photo.setPhoto(ownerID: data.id, photoID: data.photoID)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        
        let row = indexPath.row
        let data = searchData[row]
        tableView.deselectRow(at: indexPath, animated: true)
        let addFriend = RPC.PM_addFriend()
        let userID = data.id!
        addFriend.uid = userID
        NetworkManager.instance.sendPacket(addFriend) { p, e in
            let manager = MessageManager.instance
            if let searchUser = manager.searchUsers[userID] {
                manager.putUser(searchUser)
                if manager.userContacts[userID] == nil {
                    manager.userContacts[userID] = searchUser
                }
            }
            
            if manager.dialogMessages[userID] == nil {
                manager.dialogMessages = SharedDictionary<Int32, SharedArray<RPC.Message>>()
            }
            
            let chatView = StoryBoard.chat.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatView.setValue(Utils.formatUserName(data), forKey: "title")
            chatView.isGroup = false
            chatView.chatID = userID
            DispatchQueue.main.async {
                self.present(chatView, animated: true)
            }
        }
    }
    
    //MARK: - Search bar Delegate Methods.
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer.reset(withTimeout: 0.3)
    }
    
    
    // API calling for Searching Contacts.
    func onSearch(_ text: String) {
        print("SEARCH \(text)")
        let query = text.ltrim([" ", "@"]).rtrim([" "])
        if query.isEmpty {
            searchData.removeAll()
            tableView.reloadData()
            return
        }
        
        DispatchQueue.main.async {
            self.searchBar.isLoading = true
        }
        
        let searchContact = RPC.PM_searchContact()
        searchContact.query = query
        NetworkManager.instance.sendPacket(searchContact) { packet, error in
            if let usersPacket = packet as? RPC.PM_users {
                
                // Append the searched user into the modal.
                for i in 0..<usersPacket.users.count - 1 {
                    
                    if let u =  usersPacket.users[i] as? RPC.UserObject {
                        MessageManager.instance.putSearchUser(u)
                        let pid = MediaManager.instance.userProfilePhotoIDs[(u.id)!] ?? 0
                        u.photoID = pid
                    }
                }
                self.searchData = usersPacket.users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else if let e = error {
                print(e.message)
            }
            DispatchQueue.main.async {
                self.searchBar.isLoading = false
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearch(searchBar.text ?? "")
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("Results")
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("Scope button")
    }
    
    //MARK: - Scroll View Delegate Method.
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}



