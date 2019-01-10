//
//  GasInfoViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 30/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class GasInfoViewController: UIViewController {
    
    @IBOutlet weak var hint: UITextView!
    override func viewDidLoad() {
        hint.text = "Gas Price is the amount you pay per unit of gas.\n\n TX fee = gas price * gas limit & is paid to miners for including your TX in a block. Higher the gas price = faster transaction, but more expensive".localized
    }
    
}
