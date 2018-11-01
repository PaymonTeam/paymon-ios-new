//
//  CellCreatedMoneyData.swift
//  paymon
//
//  Created by Maxim Skorynin on 02.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class CellCreatedMoneyData : CellMoneyData {
    var fiatHint : String!
    var currancyAmount : Decimal!
    var fiatAmount : Decimal!
    var cryptoHint : String!
    var fiatColor : UIColor!
}
