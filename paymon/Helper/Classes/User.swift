//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation

class User {
    public static var currentUser: RPC.PM_userFull!
    public static var isAuthenticated = false
    public static var notificationWorry = true
    public static var notificationVibration = true
    public static var notificationTransactions = false
    public static var notificationMessageSound = ""
    public static var notificationTransactionSound = ""

    public static var securityPasscode = false
    public static var securityPasscodeValue = ""
    
    public static var userId : String = ""
    
    public static func saveConfig() {
        if currentUser != nil {
            let stream = SerializedStream()
            currentUser!.serializeToStream(stream: stream!)
            let userString = stream!.out.base64EncodedString()
            KeychainWrapper.standard.set(userString, forKey: "user", withAccessibility: KeychainItemAccessibility.always)
        } else {
            KeychainWrapper.standard.removeObject(forKey: "user")
        }
        
        print("User save config")
    }

    public static func loadConfig() {
        print("load config")

        if currentUser == nil {
            if let retrievedString = KeychainWrapper.standard.string(forKey: "user") {
                let data = Data(base64Encoded: retrievedString)
                let stream = SerializedStream(data: data)
                if let deserialize = try? RPC.UserObject.deserialize(stream: stream!, constructor: stream!.readInt32(nil)) {
                    if (deserialize is RPC.PM_userFull) {
                        currentUser = deserialize as? RPC.PM_userFull;
                        self.userId = String(currentUser.id)
                    } else {
                        return
                    }
                } else {
                    print("Error deser user")
                    return
                }
                stream!.close()
            } else {
                return
            }
        }
        
        securityPasscode = UserDefaults.standard.bool(forKey: UserDefaultKey.SECURITY_PASSCODE + userId)
        securityPasscodeValue = UserDefaults.standard.string(forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId) ?? ""

    }
    
    public static func savePasscode(passcodeValue : String, setPasscode : Bool) {
        securityPasscode = setPasscode
        securityPasscodeValue = passcodeValue
        UserDefaults.standard.set(setPasscode, forKey: UserDefaultKey.SECURITY_PASSCODE + userId)
        UserDefaults.standard.set(passcodeValue, forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId)
    }

    public static func clearConfig() {
        isAuthenticated = false
        KeychainWrapper.standard.removeObject(forKey: "user")
        currentUser = nil
        notificationWorry = true
        notificationVibration = true
        notificationTransactions = false
        notificationMessageSound = "Note.mp3"
        securityPasscode = false
        securityPasscodeValue = ""
    }
}
