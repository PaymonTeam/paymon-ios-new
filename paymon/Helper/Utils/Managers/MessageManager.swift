//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit

public class MessageManager {
    static var shared = MessageManager()
    var isChatsLoaded = false
    var lastMessageID = Utils.Atomic<Int64>()
    
    public static func dispose() {
        self.shared = MessageManager()
    }

    public func generateMessageID() -> Int64 {
        return lastMessageID.incrementAndGet()
    }

    public func loadChats() {

        self.isChatsLoaded = true

        if User.currentUser == nil {
            self.isChatsLoaded = false
            return
        }
        let packet = RPC.PM_chatsAndMessages()
        let _ = NetworkManager.shared.sendPacket(packet) { p, e in
            if (p == nil || e != nil) {
                print("Error request")
                return
            }
            
            if let packet = p as? RPC.PM_chatsAndMessages {
                UserDataManager.shared.updateUsers(packet.users)
                GroupDataManager.shared.updateGroups(packet.groups)
                MessageDataManager.shared.updateMessages(packet.messages)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .endUpdateChats, object: nil)
            }
            self.isChatsLoaded = false
        }
    }
    
    public func sendMessage(text : String, isGroup : Bool, chatId : Int32!) {
        
        let message = RPC.PM_message()
        message.id = lastMessageID.incrementAndGet()
        message.text = text
        message.flags = RPC.Message.MESSAGE_FLAG_FROM_ID
        message.date = Int32(Utils.currentTimeMillis() / 1000)
        message.from_id = User.currentUser!.id
        message.to_peer = isGroup ? RPC.PM_peerGroup(group_id: chatId) : RPC.PM_peerUser(user_id : chatId)
        message.to_id = chatId
        message.unread = true
        message.itemType = .NONE
        
        NetworkManager.shared.sendPacket(message) { p, e in
            if p == nil || e != nil {return}
            if let update = p as? RPC.PM_updateMessageID {
                message.id = update.newID
//                DispatchQueue.main.sync {
                    MessageDataManager.shared.updateMessage(messageObject: message)
//                }
            }
        }
    }
}
