//
//  CountryPickerViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 28.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class CountryPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var selectCountry : String!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var countries : [String]!
    
    var filteredData = [String]()
    var isSearching = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellCountry", for: indexPath) as? CountryCell {
            
            cell.title.text = filteredData[indexPath.row]
            
            cell.accessoryType = cell.title.text == selectCountry ? .checkmark : .none
            
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CountryCell {
            selectCountry = cell.title.text
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredData = countries
            tableView.reloadData()
            return
        }

        filteredData = countries.filter({country -> Bool in
            return country.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchBar.delegate = self
        
        searchBar.returnKeyType = .done
        
        countries = Utils.getAllCountries()
        filteredData = countries
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationBar.topItem?.title = "Countries".localized
        searchBar.placeholder = "Enter your country".localized
        
        if let user = User.currentUser {
            selectCountry = user.country
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        guard let user =  User.currentUser else {
//            return
//        }
//
//        user.country = selectCountry
        
    }

}

class CountryCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
}
