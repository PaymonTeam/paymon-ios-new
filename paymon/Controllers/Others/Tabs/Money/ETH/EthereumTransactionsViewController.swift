//
//  EthereumTransactionsViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class EthereumTransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var transactionsTableView: UITableView!
    
    private var updateEthTransactions: NSObjectProtocol!
    
    var transactions : [Transaction] = []
    var transactionsShow : [Transaction] = []
    
    @IBAction func filterClick(_ sender: Any) {
        let filterMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        
        let received = UIAlertAction(title: "Received".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.transactionsShow = self.transactions.filter({transaction -> Bool in
                return transaction.type == TransactionType.received
            })
            
            self.transactionsTableView.reloadData()
            
        })
        let sent = UIAlertAction(title: "Sent".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.transactionsShow = self.transactions.filter({transaction -> Bool in
                return transaction.type == TransactionType.sent
            })
            
            self.transactionsTableView.reloadData()
            
        })
        
        let all = UIAlertAction(title: "All".localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.transactionsShow = self.transactions
            
            self.transactionsTableView.reloadData()
            
        })
        
        filterMenu.addAction(cancel)
        filterMenu.addAction(sent)
        filterMenu.addAction(received)
        filterMenu.addAction(all)
        
        self.present(filterMenu, animated: true, completion: nil)
    }
    
    @IBAction func updateClick(_ sender: Any) {
        
        transactions.removeAll()

        DispatchQueue.main.async {
            self.transactionsTableView.reloadData()
            self.loading.startAnimating()
        }
        EthereumManager.shared.updateTxHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateEthTransactions = NotificationCenter.default.addObserver(forName: .updateEthTransactions, object: nil, queue: nil) {
            notification in
            self.getLoadedTx()
        }
    }
    
    func getLoadedTx() {
        EthTransactions.getTransactions() { result in
            self.transactions = result
            self.transactionsShow = result

            DispatchQueue.main.async {
                self.transactionsTableView.reloadData()
                self.loading.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loading.startAnimating()
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "History".localized
        
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        
        self.getLoadedTx()
        EthereumManager.shared.updateTxHistory()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !transactions.isEmpty {
            return transactionsShow.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !transactionsShow.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTransaction") as? TransactionTableViewCell else {return UITableViewCell()}
            let data = transactionsShow[indexPath.row]

            cell.configure(data: data)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty") as! TransEmptyTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TransactionTableViewCell {
            guard let ethTxInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.ethTxInfoViewController) as? EthTxInfoViewController else {return}
            ethTxInfoViewController.tx = cell.txInfo
            
            self.navigationController?.pushViewController(ethTxInfoViewController, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(updateEthTransactions)
    }
}
