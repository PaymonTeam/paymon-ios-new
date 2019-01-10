//
//  MoreTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 02/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {

    @IBOutlet weak var help: UILabel!
    @IBOutlet weak var games: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        help.text = "Help".localized
        games.text = "Games".localized
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let alert = UIAlertController(title: "FAQ".localized, message: "Open in browser?".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Open".localized, style: .default, handler: { _ in
                
            })
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
