//
//  LoginController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/10.
//

import UIKit

class LoginController: UIViewController {

    
    //MARK: Fucntions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: Button Actions

    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        let signUpViewStoryboard = UIStoryboard(name: "SignUpView", bundle: nil)
        let nextViewController = signUpViewStoryboard.instantiateViewController(withIdentifier: "signupVC") as! SignUpController
        self.present(nextViewController, animated: true, completion: nil)
        
    }
    
    
}
