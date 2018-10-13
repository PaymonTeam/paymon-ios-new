//
//  CacheManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 06/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import CoreData

class CacheManager {
    private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "paymon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
         
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static func save () {
        
        if context.hasChanges {
            do {
                try context.save()
                print("SAVED")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public static func saveUser(userObject : RPC.UserObject) {
        
        if !checkUserExist(id: userObject.id) {
            let userData = UserData(context: CacheManager.context)
            
            userData.setValue(userObject.last_name, forKey: "surname")
            userData.setValue(userObject.photoUrl.url, forKey: "photoUrl")
            userData.setValue(userObject.login, forKey: "login")
            userData.setValue(userObject.first_name, forKey: "name")
            userData.setValue(userObject.id, forKey: "id")
            
            userData.setValue(userObject.email, forKey: "email")
            
            CacheManager.save()
        }
        
        
    }
    
    
    static func checkUserExist(id : Int32) -> Bool {
        let fetchRequest : NSFetchRequest<UserData> = UserData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try CacheManager.context.count(for: fetchRequest)
            if count == 0 {
                print("User не используется - сохранить")
                return false
            } else {
                print("User уже существует - отмена")

                return true
            }
        } catch let error {
            print("Could not fetch \(error)")
            return true
        }
    }
    
    public static func loadUsers() -> [UserData] {
        
        var result = [UserData]()
        
        do {
            
            let fetchRequest : NSFetchRequest<UserData> = UserData.fetchRequest()
            guard let users = try CacheManager.context.fetch(fetchRequest) as? [UserData] else {
                print("Cant return users")
                return [UserData]()
            }
            
            result = users

        } catch let error{
            print("Cant load users from CoreData \(error)", error.localizedDescription)
        }
        
        
        return result
    }
}
