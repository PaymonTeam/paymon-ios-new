//
//  OfficialDocsViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 09/01/2019.
//  Copyright © 2019 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class OfficialDocsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var titleString = ""
    var text = ""
    
    override func viewDidLoad() {
        
        self.textView.text = text
        self.title = titleString
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
    }
}
