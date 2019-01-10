//
//  EthTxInfoViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 25/12/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class EthTxInfoViewController : PaymonViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    
    var tx : EthTransaction!
    var txInfo : [EthTxInfoData] = []
    
    override func viewDidLoad() {
        setLayoutOptions()
        tableView.delegate = self
        tableView.dataSource = self
        
        if tx != nil {
            txInfo.append(EthTxInfoData(title: "Hash".localized, info: tx.hash))
            txInfo.append(EthTxInfoData(title: "Confirmations".localized, info: tx.confirmations))
            txInfo.append(EthTxInfoData(title: "Date".localized, info: tx.timeStamp))
            txInfo.append(EthTxInfoData(title: "From".localized, info: tx.from))
            txInfo.append(EthTxInfoData(title: "To".localized, info: tx.to))
            txInfo.append(EthTxInfoData(title: "Value".localized, info: tx.value))
            txInfo.append(EthTxInfoData(title: "Gas Limit".localized, info: tx.gas))
            txInfo.append(EthTxInfoData(title: "Gas Used By Transaction".localized, info: tx.gasUsed))
            txInfo.append(EthTxInfoData(title: "Gas Price".localized, info: tx.gasPrice))
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "txInfoCell") as? TxInfoTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(data: txInfo[indexPath.row], row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Etherscan info".localized, message: "Open in browser?".localized, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Open".localized, style: .default, handler: { _ in
                if let hash = self.txInfo[0].info {
                    UIApplication.shared.open(URL(string: "https://etherscan.io/tx/\(hash)")!, options: [:], completionHandler: nil)
                }
            })
            let cancel = UIAlertAction(title: "Cancel".localized, style: .default, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setLayoutOptions() {
        self.title = "Информация о транзакции"
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
    }
}

