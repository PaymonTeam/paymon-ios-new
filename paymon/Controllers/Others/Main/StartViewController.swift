//
// Created by Vladislav on 24/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import UIKit

class StartViewController: PaymonViewController {

//    @IBOutlet weak var logo: UIImageView!
//    @IBOutlet weak var signUp: UIButton!
//    @IBOutlet weak var signIn: UIButton!
//    @IBOutlet weak var hint: UILabel!
//

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var hintLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!

    @IBAction func signInAction(_ sender: Any) {
        let signInViewController = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.signInViewController) as! SignInViewController
        present(signInViewController, animated: true)

    }
    @IBAction func signUpAction(_ sender: Any) {
        let signUpViewController = storyboard?.instantiateViewController(withIdentifier: VCIdentifier.signUpViewController) as! SignUpViewController
        present(signUpViewController, animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hintLbl.text = "Already have an account?".localized

        signInBtn.setTitle("sign in".localized, for: .normal)
        signUpBtn.setTitle("sign up".localized, for: .normal)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.addUIViewBackground(name: "MainBackground")

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}
