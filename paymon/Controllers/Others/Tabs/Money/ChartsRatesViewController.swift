//
//  ChartsRatesViewController.swift
//  ExchangeRatesParser
//
//  Created by Maxim Skorynin on 11.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit
import ScrollableGraphView
//import Charts

class ChartsRatesViewController: PaymonViewController, UITabBarDelegate, ScrollableGraphViewDataSource {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var viewForGraph: UIView!
    private var updateCharts : NSObjectProtocol!

    var graphView : ScrollableGraphView!
    
    var crypto = ""
    var fiat = ""
    
    var urlHour = ""
    var urlDay = ""
    var urlWeek = ""
    var urlOneMonth = ""
    var urlThreeMonths = ""
    var urlSixMonths = ""
    var urlYear = ""
    
    lazy var dataValues = [Double]()
    lazy var dataDates = [String]()

    
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
            ExchangeRatesForChartsParser.shared.parse(urlString: urlHour, interval: ExchangeRatesConst.hour)
        case 1:
            ExchangeRatesForChartsParser.shared.parse(urlString: urlDay, interval: ExchangeRatesConst.day)
        case 2:
            ExchangeRatesForChartsParser.shared.parse(urlString: urlWeek, interval: ExchangeRatesConst.week)
        case 3:
            ExchangeRatesForChartsParser.shared.parse(urlString: urlOneMonth, interval: ExchangeRatesConst.oneMonth)
        case 4:
            ExchangeRatesForChartsParser.shared.parse(urlString: urlThreeMonths, interval: ExchangeRatesConst.threeMonth)
        case 5:
            ExchangeRatesForChartsParser.shared.parse(urlString: urlSixMonths, interval: ExchangeRatesConst.sixMonth)
        case 6:
            ExchangeRatesForChartsParser.shared.parse(urlString: urlYear, interval: ExchangeRatesConst.year)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        
        updateCharts = NotificationCenter.default.addObserver(forName: .updateCharts, object: nil, queue: OperationQueue.main ){ notification in
            
            if let update = notification.object as? Rate {
                self.dataValues = update.values
                self.dataDates = update.dates
            
                DispatchQueue.main.async {
                    if self.graphView != nil {
                        self.graphView.removeFromSuperview()
                    }
                    self.graphView = self.createMultiPlotGraphOne(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.viewForGraph.frame.height))
                    self.viewForGraph.addSubview(self.graphView)

                }
            }
        }
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .landscape
        setLayoutOptions()
//        graphView = createMultiPlotGraphOne(CGRect(x: 0, y: 10, width: self.view.frame.height, height: self.viewForGraph.frame.width-80))

//        viewForGraph.addSubview(graphView)

        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]
        
        urlHour = String(format: ExchangeRatesConst.urlChartsHour, crypto, fiat)
        urlDay = String(format: ExchangeRatesConst.urlChartsDay, crypto, fiat)
        urlWeek = String(format: ExchangeRatesConst.urlChartsWeek, crypto, fiat)
        urlOneMonth = String(format: ExchangeRatesConst.urlChartsOneMonth, crypto, fiat)
        urlThreeMonths = String(format: ExchangeRatesConst.urlChartsThreeMonths, crypto, fiat)
        urlSixMonths = String(format: ExchangeRatesConst.urlChartsSixMonths, crypto, fiat)
        urlYear = String(format: ExchangeRatesConst.urlChartsYear, crypto, fiat)
        
        ExchangeRatesForChartsParser.shared.parse(urlString: urlHour, interval: ExchangeRatesConst.hour)
    }
    
    func setLayoutOptions() {
        self.navigationBar.setTransparent()
        
        self.tabBar.setTransparent()
        
        self.view.setGradientLayer(frame: CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width), topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        self.backItem.title = "Back".localized
        
        self.navigationBar.topItem?.title = "\(crypto) - \(fiat)"
        if let tabItems = self.tabBar.items as [UITabBarItem]? {
            tabItems[0].title = "1 Hour".localized
            tabItems[1].title = "1 Day".localized
            tabItems[2].title = "1 Week".localized
            tabItems[3].title = "1 Month".localized
            tabItems[4].title = "3 Months".localized
            tabItems[5].title = "6 Months".localized
            tabItems[6].title = "1 Year".localized

        }
    }
    
    func createMultiPlotGraphOne(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        // Setup the first plot.
        let line = LinePlot(identifier: "line")
        
        line.lineColor = UIColor.white
        line.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        line.shouldFill = true
        
        line.fillType = ScrollableGraphViewFillType.gradient
        line.fillGradientType = ScrollableGraphViewGradientType.linear
        line.fillGradientStartColor = UIColor.white
        line.fillGradientEndColor = UIColor.clear
        
        line.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // dots on the line
        let dots = DotPlot(identifier: "dot")
        dots.dataPointType = ScrollableGraphViewDataPointType.circle
        dots.dataPointSize = 2
        dots.dataPointFillColor = UIColor.white
        
        dots.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.relativePositions = [0, 0.2, 0.4, 0.6, 0.8, 1]
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.clear
        
        graphView.dataPointSpacing = 80
        
        graphView.shouldAdaptRange = true
        graphView.shouldRangeAlwaysStartAtZero = false
        
        graphView.shouldAnimateOnStartup = true
        
        // Add everything to the graph.
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: line)
        graphView.addPlot(plot: dots)
        
        return graphView
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // Return the data for each plot.
        switch(plot.identifier) {
        case "line":
            return dataValues[pointIndex]
        case "dot":
            return dataValues[pointIndex]
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return dataDates[pointIndex]
    }
    
    func numberOfPoints() -> Int {
        return dataDates.count
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(updateCharts)
    }
}
