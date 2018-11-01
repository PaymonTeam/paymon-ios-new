//
//  TransactionsViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 24.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var transactionsTableView: UITableView!
    
    private var updateTransactions : NSObjectProtocol!

    var transactions : [BitcoinTransaction] = []
    
    var transactionsShow : [BitcoinTransaction] = []
    
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
        BitcoinTransactions.getTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        BitcoinTransactions.getTransactions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loading.startAnimating()
        
        navigationBar.setTransparent()
        navigationBar.topItem?.title = "History".localized
        
        updateTransactions = NotificationCenter.default.addObserver(forName: .updateTransaction, object: nil, queue: OperationQueue.main ){ notification in
            
            if let transactions = notification.object as? [BitcoinTransaction] {
                self.transactions = transactions
                self.transactionsShow = transactions
                
                DispatchQueue.main.async {
                    self.transactionsTableView.reloadData()
//                    self.tableHeightConstraint.constant = self.transactionsTableView.contentSize.height
                    self.loading.stopAnimating()
                }
            }
        }
        
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !transactions.isEmpty {
            return transactionsShow.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !transactions.isEmpty {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTransaction") as? TransactionTableViewCell else {return UITableViewCell()}
            
            let data = transactionsShow[indexPath.row]
            
            cell.avatar.image = data.avatar
            cell.amount.text = data.amount
            cell.time.text = data.time
            cell.from.text = data.from
            
            switch data.type {
            case .received:
                cell.amount.textColor = UIColor.AppColor.Green.recivedTrans
            case .sent:
                cell.amount.textColor = UIColor.AppColor.Red.sentTrans
            }
        
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEmpty") as! TransEmptyTableViewCell

            return cell
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(updateTransactions)
    }
}
