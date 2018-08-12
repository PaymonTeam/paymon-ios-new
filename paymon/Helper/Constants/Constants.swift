//
//  Constants.swift
//  paymon
//
//  Created by Jogendar Singh on 26/06/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import Foundation

struct StoryBoardIdentifier {
    static let receiveEthernVC = "ReceiveViewController"
    static let sendVCStoryID = "SendViewController"
    static let scanVCStoryID = "ScanViewControllerID"
    static let chooseCurrencyVCStoryID = "ChooseCurrencyViewController"
    static let CoinDetailsVCStoryID = "CoinDetailsViewController"
    static let startViewController = "StartViewController"

}

struct UserDefaultKey {
    static let ethernAddress = "ethernAdd"
}

struct Ethereum {
    static let rinkebyEnodeRawUrl = "enode://a24ac7c5484ef4ed0c5eb2d36620ba4e4aa13b8c84684e1b4aab0cebea2ae45cb4d375b77eab56516d34bfbd3c1a833fc51296ff084b770b94fb9028c4d25ccf@52.169.42.101:30303?discport=30304"
    static let ropstenEnodeRawUrl = "enode://a24ac7c5484ef4ed0c5eb2d36620ba4e4aa13b8c84684e1b4aab0cebea2ae45cb4d375b77eab56516d34bfbd3c1a833fc51296ff084b770b94fb9028c4d25ccf@52.169.42.101:30303?discport=30304"
}

struct Etherscan {
    static let apiKey = "1KDW41TE2CPJI7DC2UWSXUWRQ6WFUR885E"
}

struct Wallet {
    static let defaultCurrency = "USD"
    static let supportedCurrencies = ["BTC","ETH","USD","EUR","CNY","GBP"]
}

struct Common {
    static let githubUrl = "https://github.com/flypaper0/ethereum-wallet"
}

struct Send {
    static let defaultGasLimit: Decimal = 21000
    static let defaultGasLimitToken: Decimal = 53000
    static let defaultGasPrice: Decimal = 2000000000
}

struct ExchangeRatesConst {
    static let urlChartsHour = "https://min-api.cryptocompare.com/data/histominute?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=60&tryConversion=false&tsym=%@"
    static let urlChartsDay = "https://min-api.cryptocompare.com/data/histominute?aggregate=10&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=144&tryConversion=false&tsym=%@"
    static let urlChartsWeek = "https://min-api.cryptocompare.com/data/histohour?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=168&tryConversion=false&tsym=%@"
    static let urlChartsOneMonth = "https://min-api.cryptocompare.com/data/histohour?aggregate=6&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=120&tryConversion=false&tsym=%@"
    static let urlChartsThreeMonths = "https://min-api.cryptocompare.com/data/histoday?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=90&tryConversion=false&tsym=%@"
    static let urlChartsSixMonths = "https://min-api.cryptocompare.com/data/histoday?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=180&tryConversion=false&tsym=%@"
    static let urlChartsYear = "https://min-api.cryptocompare.com/data/histoday?aggregate=1&e=CCCAGG&extraParams=CryptoCompare&fsym=%@&limit=365&tryConversion=false&tsym=%@"
}
