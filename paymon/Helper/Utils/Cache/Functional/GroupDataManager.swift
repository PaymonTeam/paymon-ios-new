//
//  GroupDataManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 17/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import CoreStore

class GroupDataManager {
    static let shared = GroupDataManager()
    
    func setGroupDataInfo(groupData : GroupData, groupObject : RPC.Group) {
        groupData.id = groupObject.id
        groupData.creatorId = groupObject.creatorID
        groupData.title = groupObject.title
        groupData.users = groupObject.users
        groupData.photoUrl = groupObject.photoUrl.url
    }
    
    func setGroupDataInfo(groupData : GroupData, groupObject : GroupData) {
        groupData.id = groupObject.id
        groupData.creatorId = groupObject.creatorId
        groupData.title = groupObject.title
        groupData.users = groupObject.users
        groupData.photoUrl = groupObject.photoUrl
    }
    
    func updateGroup(groupObject : RPC.Group) {
        do {
            try CoreStore.defaultStack.perform(synchronous: {(transaction) -> Void in
                
                if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == groupObject.id)) {
                    print("Group существует, я ее обновлю")
                    self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
                } else {
                    print("Group не существует, я ее создаю")
                    let groupData = transaction.create(Into<GroupData>())
                    self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
                }
            })
        } catch let error {
            print("Couldn't update Group", error)
        }
    }
    
    func updateGroup(groupObject : GroupData) {
        do {
            try CoreStore.defaultStack.perform(synchronous: {(transaction) -> Void in
                
                if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == groupObject.id)) {
                    print("Group существует, я ее обновлю")
                    self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
                } else {
                    print("Group не существует, я ее создаю")
                    let groupData = transaction.create(Into<GroupData>())
                    self.setGroupDataInfo(groupData : groupData, groupObject : groupObject)
                    
                }
            })
        } catch let error {
            print("couldn't update group", error)
        }
        
    }
    
    func updateGroupUrl(id : Int32, url : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == id)) {
                groupData.photoUrl = url
            }
        }, completion: { _ in })
    }
    
    func updateGroupTitle(id : Int32, title : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let groupData = transaction.fetchOne(From<GroupData>().where(\.id == id)) {
                groupData.title = title
            }
        }, completion: { _ in
//            (result) -> Void in
//            switch result {
//            case .success: print("Success update groupData title")
//            case .failure(let error): print("Failure update groupData title\(error)")
//            }
        })
    }
    
    func getAllGroups() -> [GroupData] {
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
    
    func updateGroups(_ groups:[RPC.Group]) {
        for group in groups {
            for userId in group.users {
                if let user = ChatsDataManager.shared.getChatByIdSync(id: userId) {
                    UserDataManager.shared.updateUserContact(id: user.id, isContact: true)
                }
                updateGroup(groupObject: group)
            }
        }
    }
}
