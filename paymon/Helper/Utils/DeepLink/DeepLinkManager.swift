//
//  DeepLinkManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 10/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

enum DeeplinkType {
    enum Messages {
        case details(chatId: Int32, title:String, subtitle:String, isGroup:Bool)
    }
    case messages(Messages)
    /*Can added more Types*/
}

let Deeplinker = DeepLinkManager()
class DeepLinkManager {
    fileprivate init() {}
    
    private var deeplinkType: DeeplinkType?
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        deeplinkType = PushNotificationManager.shared.handelPushNotification(userInfo: userInfo)
        print("handle yeeeees")
        if UIApplication.shared.applicationState == .active {
            print("app on the background")
            checkDeepLink()
        }
    }
    
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
        
        self.deeplinkType = nil
    }
}

