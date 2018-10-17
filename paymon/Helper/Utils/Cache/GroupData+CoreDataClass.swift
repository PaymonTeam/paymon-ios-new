//
//  GroupData+CoreDataClass.swift
//  paymon
//
//  Created by Maxim Skorynin on 16/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(GroupData)
public class GroupData: NSManagedObject {
    @NSManaged public var id: Int32
    @NSManaged public var creatorId: Int32
    @NSManaged public var title: String?
    @NSManaged public var users: [Int32]
    @NSManaged public var photoUrl: String?
}
