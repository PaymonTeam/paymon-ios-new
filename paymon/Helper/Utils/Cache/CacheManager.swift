////
////  CacheManager.swift
////  paymon
////
////  Created by Maxim Skorynin on 06/10/2018.
////  Copyright © 2018 Maxim Skorynin. All rights reserved.
////
//

import Foundation
import CoreStore
import CoreData

public class CacheManager {
    
    static let shared = CacheManager()
    static var isAddedStorage = false
    private var storage : LocalStorage?
    
    func initDb() {
        print("Start init")
            CoreStore.defaultStack = DataStack(
                xcodeModelName: "paymon",
                migrationChain: []
            )
//        if storage == nil {
            self.storage = CoreStore.defaultStack.addStorage(
                SQLiteStore(fileName: "Paymon_\(String(describing: User.currentUser.id!)).sqlite",
                    localStorageOptions: .preventProgressiveMigration),
                
                completion: { (result) -> Void in
                    if result.isSuccess {
                        print("Added storage Paymon")
                        CacheManager.isAddedStorage = true
                        NotificationCenter.default.post(name: .setMainController, object: nil)
                        UserDataManager.shared.updateOrCreateUser(userObject: User.currentUser)
                    }
            }) as? LocalStorage
//        }
    }
    
    func removeDb() {
//        CoreStore.defaultStack = DataStack()
        CacheManager.isAddedStorage = false
    }
}
