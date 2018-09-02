//
//  ExchangeRetesViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 03.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class ExchangeRetesViewController: PaymonViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UITableView!
    
    @IBOutlet weak var ratesTableView: UITableView!
    
    var exchangeRates : [ExchangeRate] = []
    
    private var updateRates : NSObjectProtocol!
    
    @IBAction func updateClick(_ sender: Any) {
        exchangeRates.removeAll()
        DispatchQueue.main.async {
            self.ratesTableView.reloadData()
            self.loading.startAnimating()
        }
        ExchangeRateParser.parseAllExchangeRates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratesTableView.delegate = self
        ratesTableView.dataSource = self
        
        self.loading.startAnimating()
        
        updateRates = NotificationCenter.default.addObserver(forName: .updateRates, object: nil, queue: OperationQueue.main ){ notification in
            
            if let exchangeRates = notification.object as? [ExchangeRate] {
                self.exchangeRates = exchangeRates
                
                DispatchQueue.main.async {
                    self.ratesTableView.reloadData()
                    self.loading.stopAnimating()
                }
            }
        }
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "Exchange rates".localized

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ExchangeRateParser.parseAllExchangeRates()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ExchangeRatesTableViewCell
        
        if let chartsRatesViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChartsRatesViewController")
            as? ChartsRatesViewController {
            chartsRatesViewController.crypto = cell.cryptoLabel.text!
            chartsRatesViewController.fiat = cell.fiatLabel.text!
            self.present(chartsRatesViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellExchange") as! ExchangeRatesTableViewCell
        
        cell.amount.setTitle("\(exchangeRates[row].value)", for: .normal)
        cell.cryptoLabel.text = exchangeRates[row].crypto
        cell.fiatLabel.text = exchangeRates[row].fiat
        
        return cell
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(updateRates)
    }
}
