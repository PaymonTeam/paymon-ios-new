//
//  FadeSegue.swift
//  paymon
//
//  Created by Maxim Skorynin on 23.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class SimpleShowSegue: UIStoryboardSegue {
    override func perform() {
        
        let sourceViewControllerView = self.source.view
        
        let destinationViewControllerView = self.destination.view
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        destinationViewControllerView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        destinationViewControllerView?.alpha = 0;
        sourceViewControllerView?.addSubview(destinationViewControllerView!);
        
        UIView.animate(withDuration: 0, animations: {
            destinationViewControllerView?.alpha = 1;
        }, completion: { (finished) in
            destinationViewControllerView?.removeFromSuperview()
            self.source.present(self.destination, animated: false, completion: nil)
        })
    }
}
