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
    private var dataStack : DataStack!
    
    func initDb() {
        print("Start init")
        dataStack = DataStack(
            xcodeModelName: "paymon",
            migrationChain: []
        )
        
        do {
            try dataStack.addStorageAndWait(SQLiteStore(fileName: "Paymon_\(String(describing: User.currentUser.id!)).sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch))
        } catch let error {
            print("Error init db", error)
        }
        
        CoreStore.defaultStack = self.dataStack
        CacheManager.isAddedStorage = true
        UserDataManager.shared.updateOrCreateUser(userObject: User.currentUser)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .setMainController, object: nil)
        }
        
//        let _ = dataStack.addStorage(
//            SQLiteStore(fileName: "Paymon_\(String(describing: User.currentUser.id!)).sqlite",
//                localStorageOptions: .preventProgressiveMigration),
//
//            completion: { (result) -> Void in
//                if result.isSuccess {
//                    print("Added storage Paymon")
        
//                }
//        })
    }
    
    func removeDb() {
        CoreStore.defaultStack = DataStack()
        CacheManager.isAddedStorage = false
    }
}
