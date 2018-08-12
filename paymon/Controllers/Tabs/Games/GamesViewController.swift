//
//  GamesViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class GamesViewController: PaymonViewController {
    
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    override func viewDidLoad() {
        topLabel.text = "I still learning how to play".localized
        bottomLabel.text = "We'll play later".localized
    }
}
