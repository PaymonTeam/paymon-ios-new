//
//  GamesViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import FLAnimatedImage

class GamesViewController: PaymonViewController {
    
    @IBOutlet weak var gamePad: UIView!
    @IBOutlet weak var background: FLAnimatedImageView!
    override func viewDidLoad() {
        
        setLayoutOptions()
    }
    
    func setLayoutOptions(){
    
        gamePad.layer.cornerRadius = gamePad.frame.height/2
        
        guard let url = Bundle.main.url(forResource: "GameBackground", withExtension: "gif") else {return}

        let gifData = try? Data(contentsOf: url)
        let imageData = FLAnimatedImage(animatedGIFData: gifData)
        background.animatedImage = imageData
        
        self.navigationItem.title = "Games".localized
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.turnPad(_:)))
        gamePad.addGestureRecognizer(tap)
    }
    
    @objc func turnPad(_ sender: UITapGestureRecognizer) {
        UIView.transition(with: gamePad, duration: 0.7, options: .transitionFlipFromRight, animations: nil, completion: nil)
        
        
    }
}
