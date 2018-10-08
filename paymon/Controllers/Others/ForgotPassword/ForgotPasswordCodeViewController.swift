//
//  ForgotPasswordCodeViewController.swift
//  paymon
//
//  Created by Maxim Skorynin on 26.07.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation

class ForgotPasswordCodeViewController: PaymonViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextItem: UIBarButtonItem!
    @IBOutlet weak var recoveryCode: UITextField!
    @IBOutlet weak var hint: UILabel!
    
    var emailValue : String!
    
    override func viewDidLoad() {
        
        setLayoutOptions()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }
    
    func setLayoutOptions() {
        
        recoveryCode.layer.cornerRadius = recoveryCode.frame.height/2
        
        self.view.addUIViewBackground(name: "MainBackground")
        
        self.title = "Recovery password".localized
        
        recoveryCode.delegate = self
        recoveryCode.placeholder = "Recovery code".localized
        hint.text = "Please enter the recovery code that was sent to you to e-mail".localized
        nextItem.title = "Next".localized
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func sendResponse() {
        //TODO: send code response function
        self.view.endEditing(true)
        
        guard let code = recoveryCode.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if code.isEmpty {
            recoveryCode.shake()
            return
        } else {
            let forgotPasswordChangeViewController = StoryBoard.forgotPassword.instantiateViewController(withIdentifier: VCIdentifier.forgotPasswordChangeViewController) as! ForgotPasswordChangeViewController
            
            forgotPasswordChangeViewController.codeValue = Int32(code)
            forgotPasswordChangeViewController.emailValue = self.emailValue
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(forgotPasswordChangeViewController, animated: true)
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        switch (textField) {
        case recoveryCode:
            return newLength <= 10
        default: break
        }
        
        return true
    }
    
    @IBAction func arrowBackItemClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
