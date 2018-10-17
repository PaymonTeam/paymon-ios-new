//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation

class User {
    public static var currentUser: RPC.PM_userSelf!
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
        
    }

    public static func loadConfig() {

        if currentUser == nil {
            if let retrievedString = KeychainWrapper.standard.string(forKey: "user", withAccessibility: KeychainItemAccessibility.always) {
                let data = Data(base64Encoded: retrievedString)
                let stream = SerializedStream(data: data)
                if let deserialize = try? RPC.UserObject.deserialize(stream: stream!, constructor: stream!.readInt32(nil)) {
                    if deserialize is RPC.PM_userSelf {
                        currentUser = deserialize as? RPC.PM_userSelf
                    } else {
                        print("load config user nil")
                        currentUser = nil
                        stream!.close()
                        return
                    }
                } else {
                    print("Error deser user")
                    stream!.close()

                    return
                }
                stream!.close()
            } else {
                print("Keychain has not user")
                return
            }
        }
        
        if !CacheManager.isAddedStorage {
            CacheManager.shared.initDb()
        }

        self.userId = String(currentUser.id)

        securityPasscode = KeychainWrapper.standard.bool(forKey: UserDefaultKey.SECURITY_PASSCODE + userId) ?? false
        securityPasscodeValue = KeychainWrapper.standard.string(forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId) ?? ""
    }
    
    public static func savePasscode(passcodeValue : String, setPasscode : Bool) {

        securityPasscode = setPasscode
        securityPasscodeValue = passcodeValue
        KeychainWrapper.standard.set(setPasscode, forKey: UserDefaultKey.SECURITY_PASSCODE + userId)
        KeychainWrapper.standard.set(passcodeValue, forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId)
    }

    public static func clearConfig() {
        isAuthenticated = false
        currentUser = nil
        notificationWorry = true
        notificationVibration = true
        notificationTransactions = false
        notificationMessageSound = "Note.mp3"
        securityPasscode = false
        securityPasscodeValue = ""
        CacheManager.isAddedStorage = false
        saveConfig()
    }
}
