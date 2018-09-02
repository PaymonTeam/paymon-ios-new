//
//  BitcoinTransferViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class BitcoinTransferViewController: PaymonViewController, UITextFieldDelegate {
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var yourWallet: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var cryptoHint: UILabel!
    @IBOutlet weak var fiatHint: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var amountAndWalletView: UIView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var fiat: UITextField!
    
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var walletInfoView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var sendBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var crypto: UITextField!
    @IBOutlet weak var yourWalletBalance: UILabel!
    
    private var getCourse : NSObjectProtocol!
    
    var cryptoValue : Double!
    var fiatValue : Double!
    
    var addressIsNotEmpty = false
    var amountIsCorrect = false

    var course : Double!
    var fiatCurrancy : String!
    
    var yourWalletBalanceValue : Double!
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
    @IBAction func yourWalletClick(_ sender: Any) {
        //TODO: Add view with information about BTC wallet
    }
    override func viewWillAppear(_ animated: Bool) {
        
        ExchangeRateParser.parseCourse(crypto: Money.btc, fiat: fiatCurrancy)
    }
    
    func getYourWalletInfo() {
        //TODO: Need to get balance of BTC wallet, public key
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayoutOptions()
        self.loading.startAnimating()
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapper.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapper)
        
        fiat.delegate = self
        crypto.delegate = self
        address.delegate = self
        
        fiat.addTarget(self, action: #selector(fiatDidChanged(_:)), for: .editingChanged)
        crypto.addTarget(self, action: #selector(cryptoDidChanged(_:)), for: .editingChanged)
        address.addTarget(self, action: #selector(addressDidChanged(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        getCourse = NotificationCenter.default.addObserver(forName: .getCourse, object: nil, queue: OperationQueue.main ){ notification in
            
            if let course = notification.object as? Double {
                self.course = course
                
                DispatchQueue.main.async {
                    self.loading.stopAnimating()
                    self.showAmountAndInfoView()
                }
            }
        }
        
    }
    
    func setLayoutOptions() {
        self.addressView.layer.cornerRadius = 30
        
        let widthScreen = UIScreen.main.bounds.width
        
        self.addressView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.addressView.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.send.setGradientLayer(frame: CGRect(x: 0, y: 0, width: send.frame.width, height: self.send.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.send.layer.cornerRadius = self.send.frame.width/2
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.amountAndWalletView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.amountAndWalletView.frame.height), topColor: UIColor.AppColor.Black.walletTableInfoLight.cgColor, bottomColor: UIColor.AppColor.Black.walletTableInfoDark.cgColor)
        
        self.amountAndWalletView.layer.cornerRadius = 30
        
        self.navigationBar.setTransparent()
        self.navigationBar.topItem?.title = "Transfer".localized
        self.address.placeholder = "Bitcoin address".localized
        self.yourWallet.setTitle("Your wallet".localized, for: .normal)
        
        self.fiatHint.alpha = 0
        self.cryptoHint.alpha = 0
        self.send.alpha = 0
        self.sendImage.alpha = 0
        self.amountView.alpha = 0
        self.walletInfoView.alpha = 0
        self.line.alpha = 0
        
        self.fiatHint.text = fiatCurrancy
        self.fiat.placeholder = fiatCurrancy
    }
    
    @objc func fiatDidChanged(_ textField : UITextField) {
        
        guard let fiatString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = fiatString
        
        if !fiatString.isEmpty && fiatString != "," && fiatString.components(separatedBy: ".").count < 3 {
            fiatValue = Double(fiatString)
            crypto.text = String(format: "%.7f", fiatValue / course)
            
            amountIsCorrect = true
        } else {
            amountIsCorrect = false
            crypto.text = ""
        }
        showSendButton()
        showHints(isEmpty: !(fiat.text?.isEmpty)! && !(crypto.text?.isEmpty)!)

    }
    
    @objc func cryptoDidChanged(_ textField : UITextField) {
        
        guard let cryptoString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = cryptoString
        
        if !cryptoString.isEmpty && cryptoString != "," && cryptoString.components(separatedBy: ".").count < 3 {
            cryptoValue = Double(cryptoString)
            fiat.text = String(format: "%.2f", cryptoValue * course)
            amountIsCorrect = true

        } else {
            amountIsCorrect = false

            fiat.text = ""
        }
        
        showSendButton()
        showHints(isEmpty: !(fiat.text?.isEmpty)! && !(crypto.text?.isEmpty)!)
    }
    
    @objc func addressDidChanged(_ textField : UITextField) {
        addressIsNotEmpty = !(textField.text?.isEmpty)! && (textField.text?.matches(Money.BITCOIN_WALLET_REGEX))!
        showSendButton()

    }
    
    @IBAction func sendClick(_ sender: Any) {
        if fiatValue < yourWalletBalanceValue {
            //TODO: present InformationViewController
        }
    }
    
    func showHints(isEmpty : Bool) {
        if isEmpty {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.fiatHint.alpha = 1
                self.cryptoHint.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.fiatHint.alpha = 0
                self.cryptoHint.alpha = 0
            })
        }
        
        self.view.layoutIfNeeded()
    }
    
    func showSendButton() {
        if addressIsNotEmpty && amountIsCorrect {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.send.alpha = 1
                self.sendImage.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.send.alpha = 0
                self.sendImage.alpha = 0

            })
        }
        
        self.view.layoutIfNeeded()
    }
    
    func showAmountAndInfoView() {
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.amountView.alpha = 1
            self.walletInfoView.alpha = 1
            self.line.alpha = 1
        })
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func unWindQrScan(_ segue: UIStoryboardSegue) {
        
        guard let qrScanVC = segue.source as? QRScannerViewController else {return}
        
        if !qrScanVC.result.isEmpty {
        
        addressIsNotEmpty = qrScanVC.resultValid

            DispatchQueue.main.async {
                self.address.text = qrScanVC.result
                self.showSendButton()
            }
        }
        
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            
            sendBottomConstraint.constant = notification.name == NSNotification.Name.UIKeyboardWillShow ? keyboardFrame!.height + 16 : 16
            
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(getCourse)
    }
}
