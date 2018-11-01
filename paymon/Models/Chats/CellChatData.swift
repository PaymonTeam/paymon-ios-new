//
//  paymon
//
//  Created by Maxim Skorynin on 24.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

public class CellChatData {
    var photoUrl:String!
    var name = ""
    var lastMessageText = ""
    var lastMessageType : PMFileManager.FileType!
    var timeString = ""
    var time:Int32 = 0
    var chatId:Int32!
}

public class CellDialogData : CellChatData {
    init(chatId : Int32, photoUrl : String, name: String, lastMessageText : String, lastMessageType : PMFileManager.FileType, time : Int32, timeString: String) {
        super.init()
        self.chatId = chatId
        self.photoUrl = photoUrl
        self.name = name
        self.lastMessageText = lastMessageText
        self.lastMessageType = lastMessageType
        self.time = time
        self.timeString = timeString

    }
}
public class CellGroupData : CellChatData {
    var lastMsgPhoto:String!
    
    init(chatId : Int32, photoUrl : String, name: String, lastMessageText : String, lastMessageType : PMFileManager.FileType, time : Int32, timeString: String, lastMsgPhoto : String) {
        super.init()
        self.chatId = chatId
        self.photoUrl = photoUrl
        self.name = name
        self.lastMessageText = lastMessageText
        self.lastMessageType = lastMessageType
        self.time = time
        self.timeString = timeString
        self.lastMsgPhoto = lastMsgPhoto

    }
}
