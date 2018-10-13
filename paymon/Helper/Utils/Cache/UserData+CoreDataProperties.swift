//
//  UserData+CoreDataProperties.swift
//  paymon
//
//  Created by Maxim Skorynin on 12/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var surname: String?
    @NSManaged public var login: String?
    @NSManaged public var photoUrl: String?

}
