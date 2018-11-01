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
}
