//
//  ChartsRatesViewController.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 11.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import Charts

class ChartsRatesViewController: PaymonViewController, UITabBarDelegate {
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var tabBar: UITabBar!
    
    var crypto = ""
    var fiat = ""
    
    var urlHour = ""
    var urlDay = ""
    var urlWeek = ""
    var urlOneMonth = ""
    var urlThreeMonths = ""
    var urlSixMonths = ""
    var urlYear = ""
    
    @IBAction func backButtonClick(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait

        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let landScape = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(landScape, forKey: "orientation")

    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlHour, crypto: crypto, fiat: fiat)
        case 1:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlDay, crypto: crypto, fiat: fiat)
        case 2:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlWeek, crypto: crypto, fiat: fiat)
        case 3:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlOneMonth, crypto: crypto, fiat: fiat)
        case 4:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlThreeMonths, crypto: crypto, fiat: fiat)
        case 5:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlSixMonths, crypto: crypto, fiat: fiat)
        case 6:
            ExchangeRatesForChartsParser.parse(lineChartView: self.lineChart, urlString: urlYear, crypto: crypto, fiat: fiat)
        default:
            print("How could you click on an element that does not exist?")
        }
    }
    
    override func viewDidLoad() {
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .landscape

        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]
        
        urlHour = String(format: ExchangeRatesConst.urlChartsHour, crypto, fiat)
        urlDay = String(format: ExchangeRatesConst.urlChartsDay, crypto, fiat)
        urlWeek = String(format: ExchangeRatesConst.urlChartsWeek, crypto, fiat)
        urlOneMonth = String(format: ExchangeRatesConst.urlChartsOneMonth, crypto, fiat)
        urlThreeMonths = String(format: ExchangeRatesConst.urlChartsThreeMonths, crypto, fiat)
        urlSixMonths = String(format: ExchangeRatesConst.urlChartsSixMonths, crypto, fiat)
        urlYear = String(format: ExchangeRatesConst.urlChartsWeek, crypto, fiat)
        
        lineChart.rightAxis.drawLabelsEnabled = false
        
        ExchangeRatesForChartsParser.parse(lineChartView: lineChart, urlString: urlHour, crypto: crypto, fiat: fiat)
        
    }
}
