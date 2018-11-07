//
//  SettingsWalletTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 05/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import UIKit

class SettingsWalletTableViewController: UITableViewController {
    
    @IBOutlet weak var usdCell: UITableViewCell!
    @IBOutlet weak var rubCell: UITableViewCell!
    @IBOutlet weak var twoSymb: UITableViewCell!
    @IBOutlet weak var fourSymb: UITableViewCell!
    @IBOutlet weak var sixSymb: UITableViewCell!
    
    override func viewDidLoad() {
        setLyoutOptions()
        loadSymbolsSettings()
        loadCurrencySettings()
    }
    
    func setLyoutOptions() {
        rubCell.textLabel?.text = "Rubles".localized
        usdCell.textLabel?.text = "Dollars".localized
        twoSymb.textLabel?.text = "2 symbols".localized
        fourSymb.textLabel?.text = "4 symbols".localized
        sixSymb.textLabel?.text = "6 symbols".localized
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                rubCell.accessoryType = .checkmark
                usdCell.accessoryType = .none
                User.saveCurrencyCode(currencyCode: Money.rub)
            case 1:
                rubCell.accessoryType = .none
                usdCell.accessoryType = .checkmark
                User.saveCurrencyCode(currencyCode: Money.usd)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                twoSymb.accessoryType = .checkmark
                fourSymb.accessoryType = .none
                sixSymb.accessoryType = .none
                User.saveSymbCount(symbCount: 2)
            case 1:
                twoSymb.accessoryType = .none
                fourSymb.accessoryType = .checkmark
                sixSymb.accessoryType = .none
                User.saveSymbCount(symbCount: 4)

            case 2:
                twoSymb.accessoryType = .none
                fourSymb.accessoryType = .none
                sixSymb.accessoryType = .checkmark
                User.saveSymbCount(symbCount: 6)

            default:
                break
            }
        default:
            break
        }
    }
    
    func loadCurrencySettings() {
        if let userCurrency = User.currencyCode as String? {
            switch userCurrency {
            case Money.rub:
                rubCell.accessoryType = .checkmark
                usdCell.accessoryType = .none
            case Money.usd:
                rubCell.accessoryType = .none
                usdCell.accessoryType = .checkmark
            default:
                
                break
            }
        }
    }
    
    func loadSymbolsSettings() {
        if let userSymbCount = User.symbCount as Int32? {
            switch userSymbCount {
            case 2:
                twoSymb.accessoryType = .checkmark
                fourSymb.accessoryType = .none
                sixSymb.accessoryType = .none
            case 4:
                twoSymb.accessoryType = .none
                fourSymb.accessoryType = .checkmark
                sixSymb.accessoryType = .none
            case 6:
                twoSymb.accessoryType = .none
                fourSymb.accessoryType = .none
                sixSymb.accessoryType = .checkmark
            default:
                
                break
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch (section) {
        case 0: return "Currency".localized
        case 1: return "A number of simbols after comma".localized
            
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch (section) {
        case 0: return "You can choose the main currency of your wallet".localized
        case 1: return "For convenience, select the number of decimal places".localized
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ExchangeRateParser.shared.parseCourseForWallet(crypto: Money.btc, fiat: User.currencyCode)
    }
}
