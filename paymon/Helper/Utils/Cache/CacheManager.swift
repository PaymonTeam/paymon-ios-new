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
    
    func initDb() {
        
        CoreStore.defaultStack = DataStack(
            xcodeModelName: "paymon",
            migrationChain: []
        )
        let _ = CoreStore.defaultStack.addStorage(
            SQLiteStore(fileName: "Paymon_\(String(describing: User.currentUser.id)).sqlite"),
            completion: { (result) -> Void in
                if result.isSuccess {
                    print("Added storage Paymon")
                    CacheManager.isAddedStorage = true
                }
        })
    }
    
    /*
     *
     *UserData
     *
     */
    
    func updateUser(userObject : RPC.UserObject) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            
            if let userData = transaction.fetchOne(From<UserData>().where(\.id == userObject.id)) {
                print("User существует, я его обновлю")
                self.setUserDataInfo(userData: userData, userObject: userObject)
                
            } else {
                print("User не существует, я его создаю")
                let userData = transaction.create(Into<UserData>())
                self.setUserDataInfo(userData: userData, userObject: userObject)

            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update user")
            case .failure(let error): print("Failure update user \(error)")
            }
        })
    }
    
    func updateUser(userData: UserData) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            
            if let userData = transaction.fetchOne(From<UserData>().where(\.id == userData.id)) {
                print("UserData существует, я его обновлю")
                self.setUserDataInfo(userData: userData, userObject: userData)

            } else {

                print("UserData не существует, я его создаю")
                let userData = transaction.create(Into<UserData>())
                self.setUserDataInfo(userData: userData, userObject: userData)
                
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update userData")
            case .failure(let error): print("Failure update userData \(error)")
            }
        })
    }
    
    func updateUserPhotoUrl(id : Int32, url : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let userContatctData = transaction.fetchOne(From<UserData>().where(\.id == id)) {
                userContatctData.photoUrl = url
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update userData url")
            case .failure(let error): print("Failure update userData url\(error)")
            }
        })
    }
    
    func getUserByIdSync(id : Int32) -> UserData? {
        
        var result : UserData! = nil

        DispatchQueue.main.sync {
            if let user = CoreStore.fetchOne(
                From<UserData>()
                    .where(\.id == id)
                ) as UserData? {
                result = user
            }
        }
        return result
    }
    
    func getUserById(id : Int32) -> UserData? {
        
        guard let user = CoreStore.fetchOne(
            From<UserData>()
                .where(\.id == id)
            ) as UserData? else {
                return nil
            }
        
        return user
    }
    
    func getAllUsers() -> [UserData] {
        
        guard let result = CoreStore.defaultStack.fetchAll(From<UserData>()) else {
            print("Could not get all user contacts")
            return [UserData]()
        }
        
        return result
    }
    

    /*
     *
     *UserContactData
     *
     */
    
    func updateUserContact(userObject : RPC.UserObject) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let userContatctData = transaction.fetchOne(From<UserContactData>().where(\.id == userObject.id)) {
                print("UserContatct существует, я его обновлю")
                self.setUserDataInfo(userData: userContatctData, userObject: userObject)
                
            } else {
                print("UserContatct не существует, я его создаю")
                let userContatctData = transaction.create(Into<UserContactData>())
                self.setUserDataInfo(userData: userContatctData, userObject: userObject)
                return
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update userContatct")
            case .failure(let error): print("Failure update userContatct \(error)")
            }
        })
    }
    
    func updateUserContact(userContact : UserContactData) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let userContatctData = transaction.fetchOne(From<UserContactData>().where(\.id == userContact.id)) {
                print("UserContatct существует, я его обновлю")
                self.setUserDataInfo(userData: userContatctData, userObject: userContact)
                
            } else {
                print("UserContatct не существует, я его создаю")
                let userContatctData = transaction.create(Into<UserContactData>())
                self.setUserDataInfo(userData: userContatctData, userObject: userContact)
                return
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update userContatct")
            case .failure(let error): print("Failure update userContatct \(error)")
            }
        })
    }
    
    func updateUserContactPhotoUrl(id : Int32, url : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let userContatctData = transaction.fetchOne(From<UserContactData>().where(\.id == id)) {
                userContatctData.photoUrl = url
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update userContatct url")
            case .failure(let error): print("Failure update userContatct url\(error)")
            }
        })
    }
    
    func getUserContactByIdSync(id : Int32) -> UserContactData? {
        
        var result = UserContactData()
        
        DispatchQueue.main.sync {
            if let user = CoreStore.fetchOne(
                From<UserContactData>()
                    .where(\.id == id)
                ) as UserContactData? {
                result = user
            }
        }
        return result
    }

    func getAllUserContacts() -> [UserContactData] {
        
        print("Get all contacts")
        guard let result = CoreStore.defaultStack.fetchAll(From<UserContactData>()) else {
            print("Could not get all user contacts")
            return [UserContactData]()
        }
        
        return result
    }
    
    /*
     *
     *GroupData
     *
     */
    
    func updateGroup(groupObject : RPC.Group) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            
            if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == groupObject.id)) {
                print("Group существует, я ее обновлю")
                self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
            } else {
                print("Group не существует, я ее создаю")
                let groupData = transaction.create(Into<GroupData>())
                self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)

            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update пroup")
            case .failure(let error): print("Failure update group \(error)")
            }
        })
    }
    
    func updateGroup(groupObject : GroupData) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            
            if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == groupObject.id)) {
                print("Group существует, я ее обновлю")
                self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
            } else {
                print("Group не существует, я ее создаю")
                let groupData = transaction.create(Into<GroupData>())
                self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
                
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update пroup")
            case .failure(let error): print("Failure update group \(error)")
            }
        })
    }
    
    func updateGroupUrl(id : Int32, url : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == id)) {
                groupData.photoUrl = url
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update groupData url")
            case .failure(let error): print("Failure update groupData url\(error)")
            }
        })
    }
    
    func updateGroupTitle(id : Int32, title : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == id)) {
                groupData.title = title
            }
        }, completion: { (result) -> Void in
            switch result {
            case .success: print("Success update groupData title")
            case .failure(let error): print("Failure update groupData title\(error)")
            }
        })
    }
    
    func getAllGroups() -> [GroupData] {
        
        print("Get all groups")
        guard let result = CoreStore.defaultStack.fetchAll(From<GroupData>()) else {
            print("Could not get all groups")
            return [GroupData]()
        }
        
        return result
    }
    
    func getGroupByIdSync(id : Int32) -> GroupData? {
        
        var result : GroupData! = nil
        
        DispatchQueue.main.sync {
            if let group = CoreStore.fetchOne(
                From<GroupData>()
                    .where(\.id == id)
                ) as GroupData? {
                result = group
            }
        }
        return result
    }
    
    func getGroupById(id : Int32) -> GroupData? {
        
        guard let group = CoreStore.fetchOne(
            From<GroupData>()
                .where(\.id == id)
            ) as GroupData? else {
            return nil
        }
        
        return group
        
    }
}
