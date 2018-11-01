//
//  MoneyViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 01.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class MoneyViewController: PaymonViewController, UITableViewDelegate, UITableViewDataSource {
    
    var moneyArray : [CellMoneyData]!
    
    @IBOutlet weak var moneyTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyTableView.delegate = self
        moneyTableView.dataSource = self

        navigationItem.title = "Wallet".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        moneyArray = [CellMoneyData]()
        getWalletsInfo()
        
    }
    
    func getWalletsInfo() {
        if moneyArray != nil {
            moneyArray.removeAll()
            /* We get the data using the class CryptoManager*/
            moneyArray.append(CryptoManager.shared.getBitcoinWalletInfo())
            moneyArray.append(CryptoManager.shared.getEthereumWalletInfo())
            moneyArray.append(CryptoManager.shared.getPaymonWalletInfo())
        }
        moneyTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getWalletsInfo()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let data = moneyArray[indexPath.row] as? CellCreatedMoneyData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCreated") as? MoneyCreatedTableViewCell else {return UITableViewCell()}
            cell.configure(data: data)
            return cell
            
        } else {
            let data = moneyArray[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellNotCreated") as? MoneyNotCreatedTableViewCell else {return UITableViewCell()}
            cell.configure(data: data, vc: self)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MoneyCreatedTableViewCell {
            
            switch cell.cryptoType {
            case .bitcoin?:
                
                guard let bitcoinWalletNavigationController = StoryBoard.bitcoin.instantiateInitialViewController() as? PaymonNavigationController else {return}
                self.navigationController?.present(bitcoinWalletNavigationController, animated: true, completion: nil)

            default:
                break
            }
            
        }
    }
}
