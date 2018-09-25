//
//  ChatsData.swift
//  paymon
//
//  Created by Maxim Skorynin on 24.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

public class CellChatData {
    var photoUrl:RPC.PM_photoURL!
    var name = ""
    var lastMessageText = ""
    var timeString = ""
    var time:Int64 = 0
    var chatID:Int32!
}

public class CellDialogData : CellChatData {
    
}
public class CellGroupData : CellChatData {
    var lastMsgPhoto:RPC.PM_photoURL!
}
