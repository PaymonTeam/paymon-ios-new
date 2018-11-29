//
//  BitcoinTransferViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.08.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit

class BitcoinTransferViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var yourWallet: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var cryptoHint: UILabel!
    @IBOutlet weak var fiatHint: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var amountAndWalletView: UIView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var fiat: UITextField!
    @IBOutlet weak var feeView: UIView!
    @IBOutlet weak var feeSwitch: UISwitch!
    @IBOutlet weak var fee: UITextField!
    @IBOutlet weak var feeHint: UILabel!
    
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var walletInfoView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var sendBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var crypto: UITextField!
    @IBOutlet weak var yourWalletBalance: UILabel!
    
    private var setBtcAddress : NSObjectProtocol!
    
    let toSatoshi:Double! = 100000000.0
    let minValueFee:Double! = 1000
    
    var cryptoValue : Double! = 0.0
    var fiatValue : Double! = 0.0
    var feeValue : Double! = 1000
    
    var addressIsNotEmpty = false
    var amountIsCorrect = false

    var course : Double!
    
    var publicKey : String!
    var yourWalletBalanceValue : Double!
    var toAddress:String! = ""
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
    @IBAction func feeSwitchClick(_ sender: Any) {
        if feeSwitch.isOn {
            fee.text = ""
            fee.isEnabled = true
            fee.font = UIFont(name: (fee.font?.fontName)!, size: 22)
            fee.textColor = UIColor.white
            feeValue = 0
        } else {
            fee.text = "Standart fee".localized
            fee.isEnabled = false
            fee.font = UIFont(name: (fee.font?.fontName)!, size: 14)
            fee.textColor = UIColor.white.withAlphaComponent(0.4)
            feeValue = 1000
        }
    }
    
    @IBAction func yourWalletClick(_ sender: Any) {
        guard let keysViewController = self.storyboard?.instantiateViewController(withIdentifier: VCIdentifier.keysViewController) as? KeysViewController else {return}
        
        keysViewController.keyValue = self.publicKey
        
        self.present(keysViewController, animated: true, completion: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        
        ExchangeRateParser.shared.parseCourse(crypto: Money.btc, fiat: User.currencyCode) { result in
            self.course = result
            
            DispatchQueue.main.async {
                self.loading.stopAnimating()
                self.showAmountAndInfoView()
            }
        }
    }
    
    func getYourWalletInfo() {

        yourWalletBalanceValue = BitcoinManager.shared.fiatBalance.double
        yourWalletBalance.text = String(format: "\(User.currencyCodeSymb) %.2f", yourWalletBalanceValue)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getYourWalletInfo()
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
        fee.addTarget(self, action: #selector(feeDidChanged(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setBtcAddress = NotificationCenter.default.addObserver(forName: .setBtcAddress, object: nil, queue: OperationQueue.main ){ notification in
            
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
        fee.text = "Standart fee".localized
        fee.isEnabled = false
        let widthScreen = UIScreen.main.bounds.width
        
        self.addressView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.addressView.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.send.setGradientLayer(frame: CGRect(x: 0, y: 0, width: send.frame.width, height: self.send.frame.height), topColor: UIColor.AppColor.Orange.bitcoinBalanceLight.cgColor, bottomColor: UIColor.AppColor.Orange.bitcoinBalanceDark.cgColor)
        
        self.send.layer.cornerRadius = self.send.frame.width/2
        self.feeView.layer.cornerRadius = self.feeView.frame.height/2
        
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        self.amountAndWalletView.setGradientLayer(frame: CGRect(x: 0, y: 0, width: widthScreen, height: self.amountAndWalletView.frame.height), topColor: UIColor.AppColor.Black.walletTableInfoLight.cgColor, bottomColor: UIColor.AppColor.Black.walletTableInfoDark.cgColor)
        
        self.amountAndWalletView.layer.cornerRadius = 30
        
        self.title = "Transfer".localized
        self.address.placeholder = "Bitcoin address".localized
        self.yourWallet.setTitle("Your wallet".localized, for: .normal)
        
        self.fiatHint.alpha = 0
        self.cryptoHint.alpha = 0
        self.send.alpha = 0
        self.sendImage.alpha = 0
        self.amountView.alpha = 0
        self.walletInfoView.alpha = 0
        self.line.alpha = 0
        
        self.fiatHint.text = User.currencyCode
        self.fiat.placeholder = User.currencyCode
        self.feeHint.text = "Network fee".localized
        self.fee.placeholder = Money.btc
        self.feeSwitch.onTintColor = UIColor.AppColor.Blue.primaryBlue
        
        self.send.isEnabled = false
    }
    
    @objc func feeDidChanged(_ textField : UITextField) {
        
        guard let feeString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = feeString
        print(feeString)
        if !feeString.isEmpty && feeString != "." && feeString.components(separatedBy: ".").count < 3 {
            feeValue = Double(feeString)! * toSatoshi
        } else {
            feeValue = 1000
        }
        print(feeValue)
    }
    
    @objc func fiatDidChanged(_ textField : UITextField) {
        
        guard let fiatString = textField.text?.replacingOccurrences(of: ",", with: ".") else {return}
        textField.text = fiatString
        
        if !fiatString.isEmpty && fiatString != "." && fiatString.components(separatedBy: ".").count < 3 {
            fiatValue = Double(fiatString)
            crypto.text = String(format: "%.7f", fiatValue / course)
            cryptoValue = fiatValue / course
            
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
        
        if !cryptoString.isEmpty && cryptoString != "." && cryptoString.components(separatedBy: ".").count < 3 {
            cryptoValue = Double(cryptoString)
            fiat.text = String(format: "%.2f", cryptoValue * course)
            fiatValue = cryptoValue * course
            amountIsCorrect = true

        } else {
            amountIsCorrect = false

            fiat.text = ""
        }
        
        showSendButton()
        showHints(isEmpty: !(fiat.text?.isEmpty)! && !(crypto.text?.isEmpty)!)
    }
    
    @objc func addressDidChanged(_ textField : UITextField) {
        toAddress = textField.text
//        addressIsNotEmpty = !(toAddress?.isEmpty)! && (toAddress?.matches(Money.BITCOIN_WALLET_REGEX))!
        //TODO: remove after tests
        addressIsNotEmpty = true
        showSendButton()

    }
    
    @IBAction func sendClick(_ sender: Any) {
        
        if feeValue * toSatoshi < minValueFee {
            _ = SimpleOkAlertController.init(title: "Network fee".localized, message: "The minimum fee is 0.00001 BTC".localized, vc: self)
            return
        }
        
        if Decimal(cryptoValue * toSatoshi + feeValue) < BitcoinManager.shared.balanceSatoshi {

            let transferInfoVC = StoryBoard.bitcoin.instantiateViewController(withIdentifier: VCIdentifier.ethereumTransferInformationViewController) as! EthereumTransferInformationViewController
            transferInfoVC.toAddress = toAddress
            transferInfoVC.balanceValue = yourWalletBalanceValue
            transferInfoVC.amountToSend = cryptoValue * toSatoshi
//            transferInfoVC.feeToSend = feeValue
            transferInfoVC.course = course

            self.navigationController?.pushViewController(transferInfoVC, animated: true)

        } else {
            _ = SimpleOkAlertController.init(title: "Transfer".localized, message: "You do not have enough money".localized, vc: self)
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
                self.send.isEnabled = true

            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.send.alpha = 0
                self.sendImage.alpha = 0
                self.send.isEnabled = false

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
    
    @objc func handleKeyboard(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            
            sendBottomConstraint.constant = notification.name == UIResponder.keyboardWillShowNotification ? keyboardFrame!.height + 16 : 16
            
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
