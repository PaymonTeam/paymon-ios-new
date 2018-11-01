//
// Created by Vladislav on 23/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation

class Config {
    
    public static let BUILD_DEBUG = true
    public static let BUILD_PRODUCTION = false
    public static let HOST = BUILD_DEBUG ? "91.226.80.26" : "91.226.80.26"
    public static let PORT:UInt16 = BUILD_PRODUCTION ? 7966 : 7968
    
}

