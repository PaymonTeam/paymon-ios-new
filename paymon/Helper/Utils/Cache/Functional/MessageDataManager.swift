//
//  MessageDataManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 17/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import CoreStore

class MessageDataManager {
    
    static let shared = MessageDataManager()
    
    func saveChatMessageData(messageData : ChatMessageData, messageObject : RPC.Message) {
        messageData.id = messageObject.id
        messageData.unread = messageObject.unread
        messageData.toId = messageObject.to_id
//        print(messageObject.from_id)
        messageData.fromId = messageObject.from_id
        messageData.date = messageObject.date
        messageData.dateString = Utils.formatDateTimeChatHeader(timestamp: messageObject.date)
        messageData.text = messageObject.text
        messageData.itemType = Int16(messageObject.itemType.rawValue)
        messageData.action = messageObject.action != nil ? messageObject.action.type : 0
    }
    
    func saveMessage(messageObject : RPC.Message) {
        CoreStore.defaultStack.perform(asynchronous: {(transaction) -> Void in
            if let messageData = transaction.fetchOne(From<ChatMessageData>().where(\.id == messageObject.id)) {
                self.saveChatMessageData(messageData: messageData, messageObject: messageObject)
            } else {
                let messageData = transaction.create(Into<ChatMessageData>())
                print("create")
                self.saveChatMessageData(messageData: messageData, messageObject: messageObject)
            }
        }, completion: { (nil) -> Void in
            
        })
    }
    
    func updateMessage(messageObject : RPC.Message) {
        saveMessage(messageObject: messageObject)
        
        if messageObject.to_peer is RPC.PM_peerUser {
            guard let uid = messageObject.from_id == User.currentUser.id ? messageObject.to_peer.user_id : messageObject.from_id else {
                    return
                }
            if let user = UserDataManager.shared.getUserByIdSync(id: uid) {
                self.setChatsDataByUserData(userObject: user, messageObject: messageObject)
            } else {
                let getUserInfo = RPC.PM_getUserInfo(user_id: uid)
                NetworkManager.shared.sendPacket(getUserInfo) { response, e in
                    if response == nil || e != nil {return}
                    if let userObject = response as? RPC.UserObject {
                        UserDataManager.shared.createUser(userObject: userObject)
                        self.setChatsDataByUserObject(userObject: userObject, messageObject: messageObject)
                    }
                }
            }
        } else {
            let gid = messageObject.to_peer.group_id
            if let group = GroupDataManager.shared.getGroupByIdSync(id: gid!) {
                if let lastMessageUser = UserDataManager.shared.getUserByIdSync(id: messageObject.from_id) {
                    ChatsDataManager.shared.updateGroupChats(groupObject : group, messageObject : messageObject, lastMessagePhotoUrl : lastMessageUser.photoUrl!)
                }
            } else {
                
            }
        }
    }
    
    func setChatsDataByUserObject(userObject : RPC.UserObject, messageObject: RPC.Message) {
        let chatsData = ChatsDataManager.shared.getChatByIdSync(id: userObject.id)
        
        if chatsData != nil {
            ChatsDataManager.shared.updateChatsInfo(chatId : chatsData!.id, itemType : Int16(messageObject.itemType.rawValue), lastMessageText : messageObject.text, photoUrl : userObject.photoUrl.url, time : messageObject.date)
        } else {
            ChatsDataManager.shared.updateUserChats(userObject: userObject, messageObject : messageObject)
        }
    }
    
    func setChatsDataByUserData(userObject : UserData, messageObject: RPC.Message) {
        let chatsData = ChatsDataManager.shared.getChatByIdSync(id: userObject.id)
        
        if chatsData != nil {
            ChatsDataManager.shared.updateChatsInfo(chatId : chatsData!.id, itemType : Int16(messageObject.itemType.rawValue), lastMessageText : messageObject.text, photoUrl : userObject.photoUrl!, time : messageObject.date)
        } else {
            ChatsDataManager.shared.updateUserChats(userObject: userObject, messageObject : messageObject)
        }
    }
    
    func updateMessages(_ messages : [RPC.Message]) {
        for message in messages {
            updateMessage(messageObject: message)
        }
    }
    
    func getMessagesByChatId(chatId : Int32) -> ListMonitor<ChatMessageData>? {

        if let result = CoreStore.defaultStack.monitorSectionedList(
            From<ChatMessageData>()
                .sectionBy(\.dateString)
                .where(\.toId == chatId)
                .orderBy(.ascending(\.date))) as ListMonitor<ChatMessageData>? {
            CoreStore.defaultStack.refreshAndMergeAllObjects()

            return result
        } else {
            print("Could not get all chats")
            return nil
        }
    }
    
    func getAllMessages() -> [ChatMessageData] {
        
        guard let result = CoreStore.defaultStack.fetchAll(From<ChatMessageData>()) else {
            print("Could not get all user contacts")
            return [ChatMessageData]()
        }
        
        return result
    }
    
}
