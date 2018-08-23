//
//  MoneyViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 01.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoneyViewController: PaymonViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var moneyArray : [CellMoneyData]!
    
    @IBOutlet weak var moneyTableView: UITableView!
    
    override func viewDidLayoutSubviews() {
        
        tableViewHeight.constant = self.moneyTableView.contentSize.height;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyTableView.delegate = self
        moneyTableView.dataSource = self
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Wallet".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        moneyArray = [CellMoneyData]()
        
        if moneyArray != nil {
            /* We get the data using the class CryptoManager*/
            moneyArray.append(CryptoManager.getBitcoinWalletInfo())
            moneyArray.append(CryptoManager.getEthereumWalletInfo())
            moneyArray.append(CryptoManager.getPaymonWalletInfo())
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let data = moneyArray[indexPath.row] as? CellCreatedMoneyData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCreated") as? MoneyCreatedTableViewCell else {return UITableViewCell()}
            cell.icon.image = UIImage(named: data.icon)
            cell.cryptoAmount.text = String(data.currancyAmount)
            cell.fiatAmount.text = String(data.fiatAmount)
            cell.cryptoHint.text = data.cryptoHint
            cell.fiatHint.text = data.fiatHint
            cell.cryptoType = data.cryptoType
            
            cell.cryptoHint.textColor = data.cryptoColor
            cell.cryptoAmount.textColor = data.cryptoColor
            cell.fiatHint.textColor = data.fiatColor
            cell.fiatAmount.textColor = data.fiatColor
            
            return cell
            
        } else {
            let data = moneyArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotCreated") as? MoneyNotCreatedTableViewCell else {return UITableViewCell()}
            cell.icon.image = UIImage(named: data.icon)
            cell.cryptoType = data.cryptoType
            cell.add.backgroundColor = data.cryptoColor
            cell.add.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MoneyCreatedTableViewCell {
            print(cell.fiatHint)
        }
    }
}
