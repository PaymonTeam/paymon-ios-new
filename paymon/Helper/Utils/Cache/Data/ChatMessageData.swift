//
//  ChatMessageData+CoreDataClass.swift
//  paymon
//
//  Created by Maxim Skorynin on 17/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ChatMessageData)
public class ChatMessageData: NSManagedObject {
    @NSManaged public var unread: Bool
    @NSManaged public var id: Int64
    @NSManaged public var toId: Int32
    @NSManaged public var fromId: Int32
    @NSManaged public var itemType: Int16
    @NSManaged public var date: Int32
    @NSManaged public var dateString: String
    @NSManaged public var text: String
    @NSManaged public var toPeer: Int32
    @NSManaged public var action: Int16
}

