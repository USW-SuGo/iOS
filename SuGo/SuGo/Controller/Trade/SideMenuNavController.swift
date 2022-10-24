//
//  SideMenuController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/28.
//

import UIKit
import SideMenu
import Alamofire

class SideMenuNavController: SideMenuNavigationController {

    var testSideMenu = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftSide = true
    }

}

class SideMenuController: UIViewController{
    
    override func viewDidLoad() {
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {

        let loginViewStoryboard  = UIStoryboard(name: "LoginView", bundle: nil)
        let nextViewController = loginViewStoryboard.instantiateViewController(withIdentifier: "loginVC") as! LoginController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true, completion: nil)
        
    }
    
}

