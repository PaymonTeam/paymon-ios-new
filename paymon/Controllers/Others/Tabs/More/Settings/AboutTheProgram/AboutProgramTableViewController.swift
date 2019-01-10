//
//  AboutProgramTableViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 02/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import StoreKit

class AboutProgramTableViewController: UITableViewController {

    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    
    @IBOutlet weak var licenseCell: UITableViewCell!
    @IBOutlet weak var evaluationCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        privacyCell.textLabel?.text = "Privacy policy".localized
        termsCell.textLabel?.text = "Agreements".localized
        licenseCell.textLabel?.text = "Licenses".localized
        evaluationCell.textLabel?.text = "Rate app".localized
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let officialDocsViewController = StoryBoard.setting.instantiateViewController(withIdentifier: VCIdentifier.officialDocsViewController) as! OfficialDocsViewController
        
        switch indexPath.row {
        case 0:
            officialDocsViewController.text = OfficialDocs.privacyPolicy
            officialDocsViewController.titleString = "Privacy policy".localized
            self.navigationController?.pushViewController(officialDocsViewController, animated: true)
        case 1:
            officialDocsViewController.text = OfficialDocs.agreements
            officialDocsViewController.titleString = "Agreements".localized
            self.navigationController?.pushViewController(officialDocsViewController, animated: true)
        case 3:
            if #available(iOS 10.0, *) {
                SKStoreReviewController.requestReview()
            }
        default: break
        }
        
        
    }
}
