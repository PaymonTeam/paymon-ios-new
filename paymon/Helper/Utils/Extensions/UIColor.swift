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
            static let lightGray = UIColor(netHex: 0xafafaf)
        }
        
        struct Blue {
            static let primaryBlueDark = UIColor(netHex: 0x198bb9)
            static let primaryBlueLight = UIColor(netHex: 0x55b0d2)
            static let primaryBlueWhite = UIColor(netHex: 0x55b5ff)
            static let primaryBlueUltraLight = UIColor(netHex: 0xeffbff)

            static let primaryBlue = UIColor(netHex: 0x0099cc)
            static let paymon = UIColor(netHex: 0x0099cc).withAlphaComponent(0.7)
            
            static let chatBlueBubble = UIColor(netHex: 0xbeefff).withAlphaComponent(1)
            
            static let ethereumBalanceLight = UIColor(netHex: 0xa0c8ff)
            static let ethereumBalanceDark = UIColor(netHex: 0x49adff)
        }
        
        struct Orange {
            static let bitcoin = UIColor(netHex: 0xf5a623).withAlphaComponent(0.7)
            static let bitcoinBalanceLight = UIColor(netHex: 0xffd7a0)
            static let bitcoinBalanceDark = UIColor(netHex: 0xffc633)
        }
        
        struct Black {
            static let primaryBlack = UIColor(netHex: 0x323232)
            static let primaryBlackLight = UIColor(netHex: 0x626262)
            static let primaryBlackUltraLight = UIColor(netHex: 0xe2e2e2)
            static let walletTableInfoDark = UIColor(netHex: 0x515151)
            static let walletTableInfoLight = UIColor(netHex: 0x6e6e6e)
        }
        
        struct Green {
            static let rub = UIColor(netHex: 0x417505).withAlphaComponent(0.6)
            static let recivedTrans = UIColor(netHex: 0x7ed321).withAlphaComponent(0.6)
            
        }
        
        struct Red {
            static let sentTrans = UIColor(netHex: 0xff6c6c).withAlphaComponent(0.6)
        }
        
        struct ChatsAction {
            static let red = UIColor(netHex: 0xd3354d)
            static let orange = UIColor(netHex: 0xf29f2c)
            static let blue = UIColor(netHex: 0x43b7adb)

        }
    }
}

