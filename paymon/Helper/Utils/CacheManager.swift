//
//  CacheManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 06/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import Cache

class CacheManager {
    public static let instance = CacheManager()
    
    var storage : Storage<String>!

    private init() {
        let diskConfig = DiskConfig(name: "floppy")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        
        storage = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: String.self)
        )
    }
    
    public func saveString(string : String, key : String) {
        try? storage.setObject(string, forKey: key)
    }
}
