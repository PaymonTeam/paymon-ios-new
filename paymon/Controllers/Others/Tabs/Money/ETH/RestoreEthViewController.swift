//
//  RestoreEthViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 23/11/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//
import Foundation
import MBProgressHUD

class RestoreEthViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var restore: UIButton!
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var passwordHint: UILabel!
    
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var enterPassword: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var downloadFile: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var downloadFileHeight: NSLayoutConstraint!
    
    @IBOutlet weak var fileNameHeight: NSLayoutConstraint!
    var password : String! = ""
    var repeatPasswordString: String! = ""
    
    var isFileLoaded = false
    var urlForRestore : URL!
    
    override func viewDidLoad() {
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        
        hint.text = "Download a backup wallet".localized
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        
        let widthScreen = UIScreen.main.bounds.width
        self.downloadFile.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.downloadFile.frame.height), topColor: UIColor.AppColor.Blue.ethereumBalanceLight.cgColor, bottomColor: UIColor.AppColor.Blue.ethereumBalanceDark.cgColor)
        
        self.title = "Restore wallet".localized
        enterPassword.placeholder = "Enter password".localized
        repeatPassword.placeholder = "Repeat password".localized
        
        passwordHint.text = "Enter the password of the wallet".localized
        
        restore.setTitle("Restore".localized, for: .normal)
        downloadFile.setTitle("Download file".localized, for: .normal)
        
        restore.layer.cornerRadius = restore.frame.height/2
        passwordView.layer.cornerRadius = 30
        downloadFile.layer.cornerRadius = 22
        
        fileName.layer.masksToBounds = true
        fileName.layer.cornerRadius = 22
        
        
    }
    
    @IBAction func clickDownloadFile(_ sender: Any) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == .import {
            if let url = urls[0] as URL? {
                self.urlForRestore = url
                self.fileName.text = url.lastPathComponent
                self.isFileLoaded = true
                self.showFileName()
            }
        }
    }
    
    func showFileName() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.downloadFileHeight.constant = 0
            self.fileNameHeight.constant = 44
            self.view.layoutIfNeeded()
        })
    }
    
    func restoreWallet() {
        
        DispatchQueue.main.async {
            let _ = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        do {
            let privateKey = try Data(contentsOf: urlForRestore)
            print(privateKey.base64EncodedString())
            EthereumManager.shared.restoreWallet(jsonData: privateKey, password: password) { ( isRestored, state) in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                if isRestored {
                    User.saveEthPasswordWallet(password: self.password)
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    switch state {
                    case RestoreResult.invalidAccount, RestoreResult.errorPassword:
                        _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "Incorrect password".localized, vc: self)
                    case RestoreResult.errorEncode:
                        _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "The file is damage".localized, vc: self)
                    case RestoreResult.someError:
                        _ = SimpleOkAlertController.init(title: "Restore wallet".localized, message: "An error occurred during recovery".localized, vc: self)
                    default: break
                    }
                }
            }
        } catch {
            print("error restore")
        }
    }
    
    @IBAction func restoreClick(_ sender: Any) {
        password = enterPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        repeatPasswordString = repeatPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if password.isEmpty {
            enterPassword.shake()
            return
        }
        
        if repeatPasswordString.isEmpty || repeatPasswordString != password{
            repeatPassword.shake()
            return
        }
        
        if !isFileLoaded {
            return
        }
        
        if !User.passwordEthWallet.isEmpty {
            let alertRemove = UIAlertController(title: "Restore wallet".localized, message: "Before you restore another wallet, make sure you back up your old wallet.".localized, preferredStyle: UIAlertController.Style.alert)
            
            if !User.isBackupEthWallet {
                alertRemove.addAction(UIAlertAction(title: "Backup".localized, style: .default, handler: { (action) in
                    guard let backupViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.backupEthWalletViewController) as? BackupEthWalletViewController else {return}
                    
                    self.navigationController?.pushViewController(backupViewController, animated: true)
                }))}
            
            alertRemove.addAction(UIAlertAction(title: "Restore".localized, style: .default, handler: { (action) in
                self.restoreWallet()
            }))
            alertRemove.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alertRemove, animated: true) {
                    () -> Void in
                }
            }
        } else {
            self.restoreWallet()
        }
        
        
    }
}
