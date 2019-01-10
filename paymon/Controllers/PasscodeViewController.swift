//
//  PasscodeViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 03/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import UIKit
import LocalAuthentication
import AudioToolbox

struct PasscodeKey{
    var type : Int
    var value : String
}

class PasscodeViewController: PaymonViewController {
    @IBOutlet weak var topElement: UIView!
    @IBOutlet weak var passcodeCollectionView: UICollectionView!
    @IBOutlet weak var circleOne: InputCirclePasscodeView!
    @IBOutlet weak var circleTwo: InputCirclePasscodeView!
    @IBOutlet weak var circleThree: InputCirclePasscodeView!
    @IBOutlet weak var circleFour: InputCirclePasscodeView!
    
    @IBOutlet weak var hint: UILabel!
    @IBOutlet weak var circlesView: UIView!
    
    var isNewPassword = false
    
    var newPassword = ""
    var repeatNewPassword = ""
    
    let passcodeKeysData : [PasscodeKey] = [
        PasscodeKey(type: 0, value: "1"),
        PasscodeKey(type: 0, value: "2"),
        PasscodeKey(type: 0, value: "3"),
        PasscodeKey(type: 0, value: "4"),
        PasscodeKey(type: 0, value: "5"),
        PasscodeKey(type: 0, value: "6"),
        PasscodeKey(type: 0, value: "7"),
        PasscodeKey(type: 0, value: "8"),
        PasscodeKey(type: 0, value: "9"),
        PasscodeKey(type: 1, value: "Touch ID"),
        PasscodeKey(type: 0, value: "0"),
        PasscodeKey(type: 2, value: "Delete".localized)
    ]
    
    var inputKeyCode = [String]()
    var inputCircles = [InputCirclePasscodeView]()
    
    let numPadCellIdent = "NumPad"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputCircles.append(self.circleOne)
        inputCircles.append(self.circleTwo)
        inputCircles.append(self.circleThree)
        inputCircles.append(self.circleFour)
        
        self.passcodeCollectionView.dataSource = self
        self.passcodeCollectionView.delegate = self
        
        setLayoutOptions()
    }
    
    func setLayoutOptions() {
        self.view.setGradientLayer(frame: self.view.bounds, topColor: UIColor.AppColor.Black.primaryBlackLight.cgColor, bottomColor: UIColor.AppColor.Black.primaryBlack.cgColor)
        
        if isNewPassword {
            hint.text = "Create a passcode".localized
        } else {
            hint.text = "Enter passcode".localized
            topElement.isHidden = true
        }
    }
    
    func clearInputRow() {
        inputKeyCode = []

        for i in 0..<4 {
            inputCircles[i].clearColor()
        }
    }
    
    func inputAction() {
        
        for i in 0..<inputKeyCode.count {
            inputCircles[i].fillColor()
        }
        
        if inputKeyCode.count == 4 {
            self.successInput()
        }
    }
    
    func successInput() {
        if !isNewPassword {
            for i in inputKeyCode {
                newPassword.append(i)
            }
            
            if newPassword == User.securityPasscodeValue {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                
                appDelegate.window?.rootViewController = tabsViewController
            } else {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                clearInputRow()
                newPassword = ""
            }
            
        } else if isNewPassword {
            
            if newPassword.isEmpty {
                for i in inputKeyCode {
                    newPassword.append(i)
                    clearInputRow()
                }
                hint.text = "Repeat passcode".localized
            } else {
                for i in inputKeyCode {
                    repeatNewPassword.append(i)
                }
                
                if repeatNewPassword == newPassword {
                    User.savePasscode(passcodeValue: newPassword, setPasscode: true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    repeatNewPassword = ""
                    circlesView.shake()
                }
            }
        }
    }
}

extension PasscodeViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.passcodeKeysData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = self.passcodeKeysData[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.numPadCellIdent, for: indexPath) as? NumPadCollectionViewCell else {return UICollectionViewCell()}
        
        switch data.type {
        case 0:
            cell.label.text = data.value
            return cell
        case 1, 2:
            cell.label.text = data.value
            cell.clearBackground()

            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width / 3 - 8
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.passcodeKeysData[indexPath.row]

        switch data.type {
        case 0:
            if inputKeyCode.count < 4 {
                self.inputKeyCode.append(data.value)
                self.inputAction()
            }
        case 1:
            let context = LAContext()
            
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Enter passcode".localized, reply: { (wasCorrect, error) in
                    
                    if wasCorrect {
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let tabsViewController = StoryBoard.tabs.instantiateViewController(withIdentifier: VCIdentifier.tabsViewController) as! TabsViewController
                            
                            appDelegate.window?.rootViewController = tabsViewController
                        }
                    } else {
                        print("incorrect Touch ID")
                    }
                    
                })
            } else {
                _ = SimpleOkAlertController.init(title: "Feature Touch ID".localized, message: "An error occurred during the update".localized, vc: self)
            }
        case 2:
            self.clearInputRow()
        default:
            break
        }
    }
}
