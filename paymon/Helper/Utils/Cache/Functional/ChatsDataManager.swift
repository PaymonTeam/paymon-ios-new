//
//  ChatsDataManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 18/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import CoreStore

class ChatsDataManager {
    
    static let shared = ChatsDataManager()
    
    func saveGroupChatMessageData(chatsData : ChatsData, groupObject : GroupData, messageObject : RPC.Message, lastMessagePhotoUrl : String) {
        chatsData.id = groupObject.id
        chatsData.photoUrl = groupObject.photoUrl!
        chatsData.title = groupObject.title!
        chatsData.time = messageObject.date
        chatsData.itemType = Int16(messageObject.itemType.rawValue)
        if  chatsData.itemType == 5 {
            chatsData.lastMessageText = "Group chat created".localized
        } else  {
            chatsData.lastMessageText = messageObject.text
        }
        chatsData.lastMessagePhotoUrl = lastMessagePhotoUrl
        chatsData.isGroup = true
    }
    
    func saveUserChatMessageData(chatsData : ChatsData, userObject : UserData, messageObject : RPC.Message) {
        print("save user")

        chatsData.id = userObject.id
        chatsData.photoUrl = userObject.photoUrl!
        chatsData.title = Utils.formatUserDataName(userObject)
        chatsData.lastMessageText = messageObject.text
        chatsData.time = messageObject.date
        chatsData.lastMessageFromId = messageObject.from_id
        chatsData.itemType = Int16(messageObject.itemType.rawValue)
        chatsData.lastMessagePhotoUrl = ""
        chatsData.isGroup = false
    }
    
    func saveUserChatMessageData(chatsData : ChatsData, userObject : RPC.UserObject, messageObject : RPC.Message) {
        print("save user")

        chatsData.id = userObject.id
        chatsData.photoUrl = userObject.photoUrl.url
        chatsData.title = Utils.formatUserName(userObject)
        chatsData.lastMessageText = messageObject.text
        chatsData.time = messageObject.date
        chatsData.lastMessageFromId = messageObject.from_id
        chatsData.itemType = Int16(messageObject.itemType.rawValue)
        chatsData.lastMessagePhotoUrl = ""
        chatsData.isGroup = false
    }
    
    func updateGroupChats(groupObject : GroupData, messageObject : RPC.Message, lastMessagePhotoUrl : String) {
            CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
                
                if let chatsData = transaction.fetchOne(From<ChatsData>().where(\.id == groupObject.id)) {
                    self.saveGroupChatMessageData(chatsData : chatsData, groupObject : groupObject, messageObject : messageObject, lastMessagePhotoUrl : lastMessagePhotoUrl)
                    
                } else {
                    let chatsData = transaction.create(Into<ChatsData>())
                    self.saveGroupChatMessageData(chatsData : chatsData, groupObject : groupObject, messageObject : messageObject, lastMessagePhotoUrl : lastMessagePhotoUrl)
                }
            }, completion: { (nil) -> Void in})
    }
    
    func updateUserChats(userObject: UserData, messageObject : RPC.Message) {
            CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
                
                if let chatsData = transaction.fetchOne(From<ChatsData>().where(\.id == userObject.id)) {
                    self.saveUserChatMessageData(chatsData : chatsData, userObject : userObject, messageObject : messageObject)
                } else {
                    let chatsData = transaction.create(Into<ChatsData>())
                    self.saveUserChatMessageData(chatsData : chatsData, userObject : userObject, messageObject : messageObject)
                }
            }, completion: { (nil) -> Void in})
    }
    
    func updateUserChats(userObject: RPC.UserObject, messageObject : RPC.Message) {
            CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
                
                if let chatsData = transaction.fetchOne(From<ChatsData>().where(\.id == userObject.id)) {
                    self.saveUserChatMessageData(chatsData : chatsData, userObject : userObject, messageObject : messageObject)
                } else {
                    let chatsData = transaction.create(Into<ChatsData>())
                    self.saveUserChatMessageData(chatsData : chatsData, userObject : userObject, messageObject : messageObject)
                }
            }, completion: { (nil) -> Void in})
    }
    
    func getChatById(chatId : Int32) -> ChatsData? {
        
        guard let chatData = CoreStore.fetchOne(
            From<ChatsData>()
                .where(\.id == chatId)
            ) as ChatsData? else {
                return nil
        }
        return chatData
    }
    
    func getChatByIdSync(id : Int32) -> ChatsData? {
        
        var result : ChatsData! = nil
        
        DispatchQueue.main.sync {
            if let user = CoreStore.fetchOne(
                From<ChatsData>()
                    .where(\.id == id)
                ) as ChatsData? {
                result = user
            }
        }
        return result
    }
    
    func updateChatsInfo(chatId : Int32, itemType : Int16, lastMessageText : String, photoUrl : String, time : Int32) {
            CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
                if let chatsData = transaction.fetchOne(From<ChatsData>().where(\.id == chatId)) {
                    chatsData.itemType = itemType
                    chatsData.lastMessageText = lastMessageText
                    chatsData.photoUrl = photoUrl
                    chatsData.time = time
                }
            }, completion: { (nil) -> Void in})
    }
    
    func updateChatsPhotoUrl(id : Int32, url : String) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let chatsData = transaction.fetchOne(From<ChatsData>().where(\.id == id)) {
                chatsData.photoUrl = url
            }
        }, completion: {_ in})
    }
    
    func getChatsDataByChatType(isGroup : Bool) -> [ChatsData] {
        
        guard let result = CoreStore.defaultStack.fetchAll(From<ChatsData>()
            .where(\.isGroup == isGroup)) else {
            print("Could not get all user contacts")
            return [ChatsData]()
        }
        CoreStore.defaultStack.refreshAndMergeAllObjects()
        return result
    }
    
    func getChatsByChatType(isGroup : Bool) -> ListMonitor<ChatsData>? {
        
        if let result = CoreStore.defaultStack.monitorList(From<ChatsData>()
            .where(\.isGroup == isGroup)
            .orderBy(.descending(\.time))) as ListMonitor<ChatsData>? {
            CoreStore.defaultStack.refreshAndMergeAllObjects()

            return result
        } else {
            print("Could not get all chats")
            return nil
        }
    }
    
    func getAllChats() -> ListMonitor<ChatsData>? {
        if let result = CoreStore.defaultStack.monitorList(From<ChatsData>()
            .orderBy(.descending(\.time))) as ListMonitor<ChatsData>? {
            CoreStore.defaultStack.refreshAndMergeAllObjects()
            return result
        } else {
            print("Could not get all chats")
            return nil
        }
    }
    
    func removeChat(chatsData : ChatsData) {
        CoreStore.perform(
            asynchronous: { (transaction) -> Void in
                transaction.delete(chatsData)
        },
            completion: { _ in
                CoreStore.defaultStack.refreshAndMergeAllObjects()
        })
    }
}
