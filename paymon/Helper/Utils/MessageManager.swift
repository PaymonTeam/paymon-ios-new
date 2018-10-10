//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit

class MessageManager : NotificationManagerListener {
    public static var instance = MessageManager()

    var messages = SharedDictionary<Int64,RPC.Message>()
    var lastMessages = SharedDictionary<Int32,Int64>()
    var lastGroupMessages = SharedDictionary<Int32,Int64>()
    var dialogMessages = SharedDictionary<Int32,SharedArray<RPC.Message>>()
    var groupMessages = SharedDictionary<Int32,SharedArray<RPC.Message>>()
    var users = SharedDictionary<Int32,RPC.UserObject>()
    var userContacts = SharedDictionary<Int32,RPC.UserObject>()
    var searchUsers = SharedDictionary<Int32,RPC.UserObject>()
    var groups = SharedDictionary<Int32,RPC.Group>()
    var groupsUsers = SharedDictionary<Int32,[Int32]>()
    var chatDatesDicts = SharedDictionary<Int32,[String]>()
    var currentChatID:Int32 = 0
    static var lastMessageID = Utils.Atomic<Int64>()

    private init() {
        NotificationManager.instance.addObserver(self, id: NotificationManager.didReceivedNewMessages)
        NotificationManager.instance.addObserver(self, id: NotificationManager.doLoadChatMessages)
    }
    
    public static func dispose() {
        self.instance = MessageManager()
    }

    public static func generateMessageID() -> Int64 {
        return lastMessageID.incrementAndGet()
    }

    deinit {
        NotificationManager.instance.removeObserver(self, id: NotificationManager.didReceivedNewMessages)
        NotificationManager.instance.removeObserver(self, id: NotificationManager.doLoadChatMessages)
    }

    public func putGroup(_ group:RPC.Group) {

        groups[group.id] = group
        groupsUsers[group.id] = group.users
        
        for user in group.users {
            guard let userObject = users[user] else {return}
            putUser(userObject)
        }
    }

    public func putUser(_ user:RPC.UserObject) {
        if users[user.id] != nil {
            return
        }

        users[user.id] = user
        if MessageManager.instance.dialogMessages[user.id] != nil {
            userContacts[user.id] = user
        }
    }

    public func putMessage(_ msg:RPC.Message, serverTime:Bool) {
        if messages[msg.id] != nil {
            return
        }

        if serverTime {
            msg.date += Int32(TimeZone.autoupdatingCurrent.secondsFromGMT())
        }
        messages[msg.id] = msg

        let currentUser:RPC.UserObject! = User.currentUser

        var chatID:Int32

        if let to_id = msg.to_peer.user_id {
            if (msg.from_id == currentUser.id) {
                chatID = to_id
            } else {
                chatID = msg.from_id
            }

            var list = dialogMessages[chatID]
            if list == nil {
                list = SharedArray<RPC.Message>()
                dialogMessages[chatID] = list
            }
            list!.append(msg)

            var ldmIndex:Int32 = 0

            if (to_id == currentUser.id && msg.from_id == currentUser.id) {
                ldmIndex = to_id
            } else {
                if (to_id == currentUser.id) {
                    ldmIndex = msg.from_id
                } else {
                    ldmIndex = to_id
                }
            }

            if lastMessages[ldmIndex] != nil {
                if !serverTime || msg.date > messages[lastMessages[ldmIndex]!]!.date {
                    lastMessages[ldmIndex] = msg.id
                }
            } else {
                lastMessages[ldmIndex] = msg.id
            }
        } else if let to_id = msg.to_peer.group_id {
            chatID = to_id

            var list = groupMessages[chatID]
            if list == nil {
                list = SharedArray<RPC.Message>()
                groupMessages[chatID] = list
            }
            list!.append(msg)

            var lgmIndex:Int32 = 0

            if (to_id == currentUser.id && msg.from_id == currentUser.id) {
                lgmIndex = to_id
            } else {
                if (to_id == currentUser.id) {
                    lgmIndex = msg.from_id
                } else {
                    lgmIndex = to_id
                }
            }

            if lastGroupMessages[lgmIndex] != nil {
                if msg.date > messages[lastGroupMessages[lgmIndex]!]!.date {
                    lastGroupMessages[lgmIndex] = msg.id
                }
            } else {
                lastGroupMessages[lgmIndex] = msg.id
            }
        }
    }

    public func loadChats(_ fromCache:Bool) {
        
        if fromCache {
            print("Load from cash")
        } else {
            if User.currentUser == nil {
                return
            }

            let packet = RPC.PM_chatsAndMessages()

            let _ = NetworkManager.instance.sendPacket(packet) { p, e in

                if (p == nil && e != nil) {
                    DispatchQueue.main.async {
                        NotificationManager.instance.postNotificationName(id: NotificationManager.dialogsNeedReload)
                    }
                    print("Error request")

                    return
                }

                if let packet = p as? RPC.PM_chatsAndMessages {
                    
                    for msg in packet.messages {
                        self.putMessage(msg, serverTime: true)
                    }
                    
                    for usr in packet.users {
                        self.putUser(usr)
                    }

                    for grp in packet.groups {
                        self.putGroup(grp)
                    }
                    
                    DispatchQueue.main.async {

                        NotificationManager.instance.postNotificationName(id: NotificationManager.dialogsNeedReload)
                    }
                }
            }
        }
    }

    public func loadMessages(chatID:Int32, count:Int32, offset:Int32, isGroup:Bool) {
        if User.currentUser == nil || chatID == 0 {
            return
        }
        let packet = RPC.PM_getChatMessages()

        if (!isGroup) {
            packet.chatID = RPC.PM_peerUser()
            packet.chatID.user_id = chatID
        } else {
            packet.chatID = RPC.PM_peerGroup()
            packet.chatID.group_id = chatID
        }
        packet.count = count
        packet.offset = offset

        NetworkManager.instance.sendPacket(packet) {response, e in
            if response == nil {
                return
            }
            if let packet = response as? RPC.PM_chatMessages {
                if (packet.messages.count == 0) {
                    return
                }

                var messagesToAdd: [Int64] = []
                for msg in packet.messages {
                    self.putMessage(msg, serverTime: true)
                    messagesToAdd.append(msg.id)
                }
                DispatchQueue.main.async {
                    NotificationManager.instance.postNotificationName(id: NotificationManager.chatAddMessages, args: messagesToAdd, true)
                }
            }
        }
    }

    func didReceivedNotification(_ id: Int, _ args: [Any]) {
        if (id == NotificationManager.didReceivedNewMessages) {
            if let messages = args[0] as? SharedArray<RPC.Message> {
                var messagesToShow:[Int64] = []
                for msg in messages.array {
                    putMessage(msg, serverTime: true)
                    var to_id = msg.to_peer.user_id
                    var isGroup = false
                    if to_id == 0 {
                        isGroup = true
                        to_id = msg.to_peer.group_id
                    }
                    if !isGroup {
                        if ((to_id == currentChatID && msg.from_id == User.currentUser!.id) || (to_id == User.currentUser!.id && msg.from_id == currentChatID)) {
                            messagesToShow.append(msg.id)
                        }
                    } else {
                        if (to_id == currentChatID) {
                            messagesToShow.append(msg.id)
                        }
                    }
                }
                if (messagesToShow.count > 0) {

                    messagesToShow.sort(by: {e1, e2 in
                        return e1 > e2
                    })

                    NotificationManager.instance.postNotificationName(id: NotificationManager.chatAddMessages, args: messagesToShow, false)
                }
            }
        }
//        else if (id == NotificationManager.doLoadChatMessages) {
//
//        }
    }

    public func updateMessageID(oldID:Int64, newID:Int64) {
        let omsg = messages[oldID]
        if let oldMessage = omsg {
            var newMessage: RPC.Message! = nil
            if (oldMessage is RPC.PM_message) {
                newMessage = RPC.PM_message()
                newMessage.text = oldMessage.text
            } else if (oldMessage is RPC.PM_messageItem) {
                newMessage = RPC.PM_messageItem()
                newMessage.itemType = oldMessage.itemType
                newMessage.itemID = oldMessage.itemID
            }
            if (newMessage != nil) {
                newMessage.id = newID
                newMessage.date = oldMessage.date
                newMessage.from_id = oldMessage.from_id
                newMessage.to_peer = oldMessage.to_peer
                newMessage.edit_date = oldMessage.edit_date
                newMessage.flags = oldMessage.flags
                newMessage.reply_to_msg_id = oldMessage.reply_to_msg_id
                newMessage.unread = oldMessage.unread
                newMessage.views = oldMessage.views

                putMessage(newMessage, serverTime: false)
                _ = messages.removeValue(forKey: oldID)
                if (newMessage.to_peer is RPC.PM_peerUser) {
                    lastMessages[newMessage.to_peer.user_id] = newMessage.id
                } else if (newMessage.to_peer is RPC.PM_peerGroup) {
                    lastGroupMessages[newMessage.to_peer.group_id] = newMessage.id
                }
            }
        }
        if (currentChatID != 0) {
            // TODO: race condition
            DispatchQueue.main.async {
                NotificationManager.instance.postNotificationName(id: NotificationManager.messagesIDdidupdated, args: oldID, newID)
            }
        }
    }
    
    public func sendMessage(text : String, isGroup : Bool, chatId : Int32!, messages: [Int64]) {
        
        var messagesId = messages
        
        let mid = MessageManager.generateMessageID()
        let message = RPC.PM_message()
        message.itemID = 0
        message.itemType = .NONE
        message.from_id = User.currentUser!.id
        if isGroup {
            message.to_peer = RPC.PM_peerGroup()
            message.to_peer.group_id = chatId
        } else {
            message.to_peer = RPC.PM_peerUser()
            message.to_peer.user_id = chatId
        }
        message.id = mid
        message.text = text
        message.date = Int32(Utils.currentTimeMillis() / 1000) + Int32(TimeZone.autoupdatingCurrent.secondsFromGMT())
        
        NetworkManager.instance.sendPacket(message) { p, e in
            if let update = p as? RPC.PM_updateMessageID {
                for i in 0..<messagesId.count {
                    if messagesId[i] == update.oldID {
                        messagesId.remove(at: i)
                        break
                    }
                }
                DispatchQueue.global().sync {
                    messagesId.append(update.newID)
                }
                
            }
        }
        messagesId.append(mid)
        
        NotificationCenter.default.post(name: .updateMessagesId, object: messagesId)
        MessageManager.instance.putMessage(message, serverTime: false)
        
    }
}
