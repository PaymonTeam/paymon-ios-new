//
// Created by Vladislav on 24/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit

class StartViewController: PaymonViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet weak var stackButtons: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayoutOptions()
    }

    func setLayoutOptions() {
        hintLbl.text = "Already have an account?".localized
        
        signInBtn.setTitle("sign in".localized, for: .normal)
        signUpBtn.setTitle("sign up".localized, for: .normal)
        
        stackButtons.layer.masksToBounds = true
        stackButtons.layer.cornerRadius = 30
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.addUIViewBackground(name: "MainBackground")

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}
