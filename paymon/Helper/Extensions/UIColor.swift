//
//  UIColors.swift
//  paymon
//
//  Created by Maxim Skorynin on 20.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIColor {
    struct AppColor {
        
        struct Gray {
            static let ethereum = UIColor(netHex: 0x9b9b9b).withAlphaComponent(0.7)
        }
        
        struct Blue {
            static let primaryBlueDark = UIColor(netHex: 0x198bb9)
            static let primaryBlueLight = UIColor(netHex: 0x55b0d2)
            static let primaryBlueWhite = UIColor(netHex: 0x55b5ff)
            static let primaryBlueUltraLight = UIColor(netHex: 0xeffbff)
            

            static let primaryBlue = UIColor(netHex: 0x0099cc)
            static let paymon = UIColor(netHex: 0x0099cc).withAlphaComponent(0.7)
        }
        
        struct Orange {
            static let bitcoin = UIColor(netHex: 0xf5a623).withAlphaComponent(0.7)
        }
        
        struct Black {
            static let primaryBlack = UIColor(netHex: 0x323232)
            static let primaryBlackLight = UIColor(netHex: 0x626262)
            static let primaryBlackUltraLight = UIColor(netHex: 0xe2e2e2)
        }
        
        struct Green {
            static let rub = UIColor(netHex: 0x417505).withAlphaComponent(0.6)
        }
    }
}

