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
    public static var timeFormatIs24 = true
    public static var userId : String = ""
    public static var currencyCode : String = "USD"
    public static var currencyCodeSymb : String = "$"
    public static var passwordBtcWallet : String = ""
    public static var passwordEthWallet : String = ""

    public static var symbCount : Int32 = 2
    public static var rowSeed : String = ""
    public static var isBackupBtcWallet : Bool = false
    public static var isBackupEthWallet : Bool = false

    
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

        print("load config")
        if currentUser == nil {

            if let retrievedString = KeychainWrapper.standard.string(forKey: "user", withAccessibility: KeychainItemAccessibility.always) {
                let data = Data(base64Encoded: retrievedString)
                let stream = SerializedStream(data: data)
                if let deserialize = try? RPC.UserObject.deserialize(stream: stream!, constructor: stream!.readInt32(nil)) {
                    if deserialize is RPC.PM_userSelf {
                        currentUser = deserialize as? RPC.PM_userSelf
                        self.setUserSettings()
                        
                        stream!.close()
                        return
                    } else {
                        currentUser = nil
                        stream!.close()
                        return
                    }
                } else {
                    print("Error deser user")
                    stream!.close()
                    return
                }
            } else {
                guard let window = UIApplication.shared.delegate?.window else {return}
                window!.rootViewController = StoryBoard.main.instantiateViewController(withIdentifier: VCIdentifier.mainNavigationController)
                return
            }
        } else {
            self.setUserSettings()
        }
    }
    
    public static func setCurrencyCodeSymb() {
        switch currencyCode {
        case Money.rub: currencyCodeSymb = "₽"
        case Money.usd: currencyCodeSymb = "$"
        default:
            break
        }
    }
    
    public static func setUserSettings() {
        
        if !CacheManager.isAddedStorage {
            print("init DB")
            CacheManager.shared.initDb()
        }
        
        self.userId = String(currentUser.id)
        
        isBackupEthWallet = KeychainWrapper.standard.bool(forKey: UserDefaultKey.IS_ETH_WALLET_BACKUP + userId) ?? false
        isBackupBtcWallet = KeychainWrapper.standard.bool(forKey: UserDefaultKey.IS_BTC_WALLET_BACKUP + userId) ?? false
        rowSeed = KeychainWrapper.standard.string(forKey: UserDefaultKey.ROW_SEED_FOR_BACKUP + userId) ?? ""
        passwordBtcWallet = KeychainWrapper.standard.string(forKey: UserDefaultKey.PASSWORD_BTC_WALLET + userId) ?? ""
        passwordEthWallet = KeychainWrapper.standard.string(forKey: UserDefaultKey.PASSWORD_ETH_WALLET + userId) ?? ""
        currencyCode = KeychainWrapper.standard.string(forKey: UserDefaultKey.CURRENCY_CODE + userId) ?? "USD"
        setCurrencyCodeSymb()
        symbCount = Int32(KeychainWrapper.standard.integer(forKey: UserDefaultKey.SYMB_COUNT + userId) ?? 2)
        timeFormatIs24 = KeychainWrapper.standard.bool(forKey: UserDefaultKey.TIME_FORMAT + userId) ?? true
        securityPasscode = KeychainWrapper.standard.bool(forKey: UserDefaultKey.SECURITY_PASSCODE + userId) ?? false
        securityPasscodeValue = KeychainWrapper.standard.string(forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId) ?? ""
        
    }
    
    public static func savePasscode(passcodeValue : String, setPasscode : Bool) {
        securityPasscode = setPasscode
        securityPasscodeValue = passcodeValue
        KeychainWrapper.standard.set(setPasscode, forKey: UserDefaultKey.SECURITY_PASSCODE + userId)
        KeychainWrapper.standard.set(passcodeValue, forKey: UserDefaultKey.SECURITY_PASSCODE_VALUE + userId)
    }
    
    public static func saveTimeFormat(is24 : Bool) {
        timeFormatIs24 = is24
        KeychainWrapper.standard.set(is24, forKey: UserDefaultKey.TIME_FORMAT + userId)
    }
    
    public static func saveCurrencyCode(currencyCode: String) {
        self.currencyCode = currencyCode
        setCurrencyCodeSymb()
        KeychainWrapper.standard.set(currencyCode, forKey: UserDefaultKey.CURRENCY_CODE + userId)
    }
    
    public static func saveSymbCount(symbCount : Int32) {
        self.symbCount = symbCount
        KeychainWrapper.standard.set(Int(symbCount), forKey: UserDefaultKey.SYMB_COUNT + userId)
    }
    
    public static func saveBtcPasswordWallet(password : String) {
        self.passwordBtcWallet = password
        KeychainWrapper.standard.set(password, forKey: UserDefaultKey.PASSWORD_BTC_WALLET + userId)
    }
    
    public static func saveSeed(rowSeed : String) {
        self.rowSeed = rowSeed
        self.isBackupBtcWallet = false
        KeychainWrapper.standard.set(rowSeed, forKey: UserDefaultKey.ROW_SEED_FOR_BACKUP + userId)
        KeychainWrapper.standard.set(false, forKey: UserDefaultKey.IS_BTC_WALLET_BACKUP + userId)
    }
    
    public static func backUpBtcWallet() {
        self.isBackupBtcWallet = true
        self.rowSeed = ""
        KeychainWrapper.standard.removeObject(forKey: UserDefaultKey.ROW_SEED_FOR_BACKUP + userId)
        KeychainWrapper.standard.set(true, forKey: UserDefaultKey.IS_BTC_WALLET_BACKUP + userId)
    }
    
    public static func saveEthPasswordWallet(password : String) {
        self.passwordEthWallet = password
        self.isBackupEthWallet = false
        KeychainWrapper.standard.set(password, forKey: UserDefaultKey.PASSWORD_ETH_WALLET + userId)
    }
    
    public static func backUpEthWallet() {
        self.isBackupEthWallet = true
        KeychainWrapper.standard.set(true, forKey: UserDefaultKey.IS_ETH_WALLET_BACKUP + userId)
    }
    
    public static func deleteEthWallet() {
        self.isBackupEthWallet = false
        self.passwordEthWallet = ""
        KeychainWrapper.standard.set(false, forKey: UserDefaultKey.IS_ETH_WALLET_BACKUP + userId)
        KeychainWrapper.standard.set("", forKey: UserDefaultKey.PASSWORD_ETH_WALLET + userId)
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
        timeFormatIs24 = true
        currencyCode = "USD"
        passwordBtcWallet = ""
        passwordEthWallet = ""
        symbCount = 2
        rowSeed = ""
        isBackupEthWallet = false
        isBackupBtcWallet = false
        CacheManager.shared.removeDb()
        saveConfig()
    }
}
