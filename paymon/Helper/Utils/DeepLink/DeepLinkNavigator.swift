//
//  DeepLinkNavigator.swift
//  paymon
//
//  Created by Maxim Skorynin on 10/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation


class DeeplinkNavigator {
    
    static let shared = DeeplinkNavigator()
    private init() {}
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .messages(.details(chatId: let chatID, title: let title, subtitle: let subtitle, isGroup: let isGroup)):
            
            print("TRY OPEN CHAT")
            let chatViewController = StoryBoard.chat.instantiateViewController(withIdentifier: VCIdentifier.chatViewController) as! ChatViewController
            
            if subtitle.isEmpty {
                chatViewController.setValue(title, forKey: "title")
            } else {
                chatViewController.setValue(subtitle, forKey: "title")
            }
            
            chatViewController.isGroup = isGroup
            
            chatViewController.chatID = chatID
            
            if let nc = UIApplication.shared.keyWindow?.rootViewController as? MainNavigationController {
                nc.navigationBar.isHidden = false
                nc.pushViewController(chatViewController, animated: true)
            }

            break
        }
    }
}
