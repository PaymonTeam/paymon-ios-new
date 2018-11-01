


import UIKit
import AudioToolbox
import UserNotifications


extension FileManager {
    func isDirectory(url:URL) -> Bool? {
        var isDir: ObjCBool = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            return nil
        }
    }
}

struct SystemSoundInfo {
    var url:URL
    let name:String
}

class NotificationSoundTableViewController: UITableViewController{
    
    let ringtone = ["Aurora", "Bamboo", "Chord", "Circles", "Complete", "Hello",
                    "Input", "Keys", "Note", "Popcorn", "Pulse", "Synth"]
    
    let mp3 = "mp3"
    let directory = "paymon/ringtone"
    
    var sounds: [SystemSoundInfo] = []
    
    @IBOutlet var notificationSoundsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sounds = sounds.sorted(by: { (a, b) -> Bool in 
            a.name > b.name
        })
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        for row in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section)) {
                cell.accessoryType = row == indexPath.row ? .checkmark : .none
            }
        }
        
        let soundItem = sounds[indexPath.item]
        
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundItem.url as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        
        User.notificationMessageSound = soundItem.url.lastPathComponent
        
//        User.saveNotificationSettings()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let soundItem = sounds[indexPath.item]
        
        if soundItem.url.lastPathComponent == User.notificationMessageSound {
            cell.accessoryType = .checkmark
        }
        
        cell.textLabel?.text = "\(soundItem.name)"
        
        return cell
    }
}
