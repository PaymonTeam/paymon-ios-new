//
//  ChatsData.swift
//  paymon
//
//  Created by Maxim Skorynin on 17/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ChatsData)
public class ChatsData: NSManagedObject {

    @NSManaged public var photoUrl: String
    @NSManaged public var title: String
    @NSManaged public var lastMessageText: String
    @NSManaged public var time: Int32
    @NSManaged public var id: Int32
    @NSManaged public var itemType: Int16
    @NSManaged public var lastMessagePhotoUrl: String
    @NSManaged public var lastMessageFromId: Int32
    @NSManaged public var isGroup: Bool
    
}
