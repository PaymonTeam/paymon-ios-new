//
//  MoneyViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 01.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoneyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var moneyArray : [CellMoneyData]!
    
    @IBOutlet weak var moneyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyTableView.delegate = self
        moneyTableView.dataSource = self
        navigationBar.setTransparent()
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        moneyArray = [CellMoneyData]()
        
        if moneyArray != nil {
            getBitcoinWalletInfo()
            getEthereumWalletInfo()
            getPaymonWalletInfo()
        }
    }
    
    func getPaymonWalletInfo() {
        let paymonData = CellCreatedMoneyData()
        /*Block for test*/
        paymonData.currancyAmount = 12.572
        paymonData.fiatAmount = 6723.13
        paymonData.cryptoHint = Money.pmnc
        paymonData.icon = Money.pmncIcon
        paymonData.fiatHint = Money.rub
        paymonData.fiatColor = UIColor.AppColor.Green.rub
        paymonData.cryptoColor = UIColor.AppColor.Blue.paymon
        /*******************/
        moneyArray.append(paymonData)
    }
    
    func getEthereumWalletInfo() {
        let ethereumData = CellCreatedMoneyData()
        /*Block for test*/
        ethereumData.currancyAmount = 4.523
        ethereumData.fiatAmount = 23552.98
        ethereumData.cryptoHint = Money.eth
        ethereumData.icon = Money.ethIcon
        ethereumData.fiatHint = Money.rub
        ethereumData.fiatColor = UIColor.AppColor.Green.rub
        ethereumData.cryptoColor = UIColor.AppColor.Gray.ethereum
        /*******************/
        
        moneyArray.append(ethereumData)
    }
    
    func getBitcoinWalletInfo() {
        let bitcoinData = CellCreatedMoneyData()
        /*Block for test*/
        bitcoinData.currancyAmount = 1.023
        bitcoinData.fiatAmount = 87403.04
        bitcoinData.cryptoHint = Money.btc
        bitcoinData.icon = Money.btcIcon
        bitcoinData.fiatHint = Money.rub
        bitcoinData.fiatColor = UIColor.AppColor.Green.rub
        bitcoinData.cryptoColor = UIColor.AppColor.Orange.bitcoin
        /*******************/
        moneyArray.append(bitcoinData)
        
        let notCreated = CellMoneyData()
        notCreated.cryptoColor = UIColor.AppColor.Gray.ethereum
        notCreated.icon = Money.ethIcon
        moneyArray.append(notCreated)
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
            
            cell.cryptoHint.textColor = data.cryptoColor
            cell.cryptoAmount.textColor = data.cryptoColor
            cell.fiatHint.textColor = data.fiatColor
            cell.fiatAmount.textColor = data.fiatColor
            
            return cell
            
        } else {
            let data = moneyArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotCreated") as? MoneyNotCreatedTableViewCell else {return UITableViewCell()}
            print("create not ")
            cell.icon.image = UIImage(named: data.icon)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MoneyCreatedTableViewCell {
            print(cell.fiatHint)
        } else if let cell = tableView.cellForRow(at: indexPath) as? MoneyNotCreatedTableViewCell{
            print(cell.icon.frame.width)
        }
        
        //TODO: Вроде не нужна
        
    }
}
