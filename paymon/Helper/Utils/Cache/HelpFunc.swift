//
//  HelpFunc.swift
//  paymon
//
//  Created by Maxim Skorynin on 16/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

extension CacheManager {
    func setUserDataInfo(userData : UserData, userObject : RPC.UserObject) {
        userData.name = userObject.first_name
        userData.surname = userObject.last_name
        userData.id = userObject.id
        userData.email = userObject.email
        userData.isEmailHidden = userObject.isEmailHidden
        userData.login = userObject.login
        userData.photoUrl = userObject.photoUrl.url
    }
    
    func setUserDataInfo(userData : UserData, userObject : UserData) {
        userData.name = userObject.name
        userData.surname = userObject.surname
        userData.id = userObject.id
        userData.email = userObject.email
        userData.isEmailHidden = userObject.isEmailHidden
        userData.login = userObject.login
        userData.photoUrl = userObject.photoUrl
    }
    
    func setGroupDataInfo(groupData : GroupData, groupObject : RPC.Group) {
        groupData.id = groupObject.id
        groupData.creatorId = groupObject.creatorID
        groupData.title = groupObject.title
        groupData.users = groupObject.users
        groupData.photoUrl = groupObject.photoUrl.url
    }
    
    func setGroupDataInfo(groupData : GroupData, groupObject : GroupData) {
        groupData.id = groupObject.id
        groupData.creatorId = groupObject.creatorId
        groupData.title = groupObject.title
        groupData.users = groupObject.users
        groupData.photoUrl = groupObject.photoUrl
    }
}
