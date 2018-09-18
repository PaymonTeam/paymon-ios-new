//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation

class Config {
    open static let BUILD_DEBUG = true
    open static let BUILD_PRODUCTION = false
    open static let HOST = BUILD_DEBUG ? "91.226.80.26" : "91.226.80.26"
    open static let PORT:UInt16 = BUILD_PRODUCTION ? 7966 : 7968

    public static let SETTINGS_NOTIFICATION = "settings_notification_"
    public static let SETTINGS_NOTIFICATION_WORRY = "settings_notification_worry"
    public static let SETTINGS_NOTIFICATION_VIBRATION = "settings_notification_vibration"
    public static let SETTINGS_NOTIFICATION_TRANSACTIONS = "settings_notification_transactions"
    public static let SETTINGS_NOTIFICATION_SOUND = "settings_notification_sound"

    public static let SETTINGS_SECURITY = "settings_security_"
    public static let SETTINGS_SECURITY_PASSWORD_PROTECTED = "settings_security_password_protected"
    public static let SETTINGS_SECURITY_PASSWORD_PROTECTED_STRING = "settings_security_password_protected_string"

}
