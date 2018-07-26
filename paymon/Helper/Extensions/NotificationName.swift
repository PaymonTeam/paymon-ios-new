//
//  NotificationName.swift
//  paymon
//
//  Created by Maxim Skorynin on 19.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let returnKeyLogin = Notification.Name(rawValue: "returnKeyLogin")
    static let login = Notification.Name(rawValue: "login")
    static let loginFalse = Notification.Name(rawValue: "loginFalse")
    static let hideIndicatorLogin = Notification.Name(rawValue: "hideIndicatorLogin")
    static let canLoginTrue = Notification.Name(rawValue: "canLoginTrue")
    static let canLoginFalse = Notification.Name(rawValue: "canLoginFalse")
    static let disableSignUpButtons = Notification.Name(rawValue: "disableSignUpButtons")
    static let enableSignUpButtons = Notification.Name(rawValue: "enableSignUpButtons")
    static let registerFalse = Notification.Name(rawValue: "registerFalse")
    static let register = Notification.Name(rawValue: "register")
    static let canRegisterTrue = Notification.Name(rawValue: "canRegisterTrue")
    static let canRegisterFalse = Notification.Name(rawValue: "canRegisterFalse")
    static let clickRegisterButton = Notification.Name(rawValue: "clickRegisterButton")
    static let updateProfile = Notification.Name(rawValue: "updateProfile")
    static let updateView = Notification.Name(rawValue: "updateView")
    static let updateString = Notification.Name(rawValue: "updateString")
    static let updateProfileInfoTrue = Notification.Name(rawValue: "updateProfileInfoTrue")
    static let updateProfileInfoFalse = Notification.Name(rawValue: "updateProfileInfoFalse")
}
