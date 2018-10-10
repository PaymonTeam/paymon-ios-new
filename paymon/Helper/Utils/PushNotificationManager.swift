//
//  PushNotificationManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 09/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UserNotifications

class PushNotificationManager {
  
    static let shared = PushNotificationManager()
    
    func registrForNotification(application : UIApplication) {
        let center = UNUserNotificationCenter.current()
//        center.delegate = application.delegate as? UNUserNotificationCenterDelegate
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
                print("Permission for notif was granted")
            }
        }
        
        let answer = UNTextInputNotificationAction(identifier: PushNotification.Action.answer, title: "Answer".localized, options: [], textInputButtonTitle: "Send".localized, textInputPlaceholder: "To write a message".localized)
        
        let skip = UNNotificationAction(identifier: PushNotification.Action.skip, title: "Skip".localized, options: [])
        let mute = UNNotificationAction(identifier: PushNotification.Action.mute, title: "Do not disturb for 8 hours".localized, options: [])
        
        let messages = UNNotificationCategory(identifier: PushNotification.Category.messages, actions: [answer, skip, mute], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([messages])
    }
    
    func handelPushNotification(userInfo: [AnyHashable : Any]) -> DeeplinkType? {
        
        if let notif = userInfo[PushNotification.Keys.APS] as? [String:Any] {
            
            let chatId = notif[PushNotification.Keys.CHAT_ID] as! Int32
            let alert = notif[PushNotification.Keys.ALERT] as! [String:String]
            let title = alert[PushNotification.Keys.TITLE]
            
            var isGroup = false

            let subtitle = alert[PushNotification.Keys.SUBTITLE]! 
            if !subtitle.isEmpty {
                isGroup = true
                return DeeplinkType.messages(.details(chatId: chatId, title:title!,subtitle: subtitle ,isGroup:isGroup))
            }
            
            return DeeplinkType.messages(.details(chatId: chatId, title:title!,subtitle: "" ,isGroup:isGroup))
        }
        
        return nil
    }
}
