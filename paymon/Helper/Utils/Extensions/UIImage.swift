//
//  UIImage.swift
//  paymon
//
//  Created by Maxim Skorynin on 04/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let image = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        image.contentMode = .scaleAspectFit
        image.image = self
        UIGraphicsBeginImageContextWithOptions(image.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        image.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let image = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        image.contentMode = .scaleAspectFit
        image.image = self
        UIGraphicsBeginImageContextWithOptions(image.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        image.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

