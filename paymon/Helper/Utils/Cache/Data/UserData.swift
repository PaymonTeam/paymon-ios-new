//
//  UserData+CoreDataClass.swift
//  paymon
//
//  Created by Maxim Skorynin on 13/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UserData)
public class UserData: NSManagedObject {
    @NSManaged public var email: String?
    @NSManaged public var id: Int32
    @NSManaged public var login: String?
    @NSManaged public var name: String?
    @NSManaged public var photoUrl: String?
    @NSManaged public var surname: String?
    @NSManaged public var isEmailHidden: Bool
    @NSManaged public var isContact: Bool
    @NSManaged public var btcAddress: String
    @NSManaged public var ethAddress: String
    @NSManaged public var pmntAddress: String

}
