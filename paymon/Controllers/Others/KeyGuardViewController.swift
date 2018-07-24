//
//  KeyGuardViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 23.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

import UIKit

class KeyGuardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var keysCollection: UICollectionView!
    
    let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "touchId", "0", "delete"]
    
    let collectionViewKeys = "keyCell"
    
    @IBOutlet weak var stackDots: UIStackView!
    
    let password = "1"
    
    override func viewDidLoad() {
        self.view.addUIViewBackground(name: "MainBackground")
        
        keysCollection.delegate = self
        keysCollection.dataSource = self

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cellKey = collectionView.dequeueReusableCell(withReuseIdentifier: "keyCell", for: indexPath) as! KeyGuardViewCell
            cellKey.view.setTitle(keys[indexPath.row], for: .normal)
            if cellKey.view.titleLabel?.text == "delete" || cellKey.view.titleLabel?.text == "touchId"{
                cellKey.layer.borderWidth = 0
            }
            return cellKey
    }
}

