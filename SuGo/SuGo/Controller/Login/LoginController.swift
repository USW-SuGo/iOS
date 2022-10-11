//
//  LoginController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/10.
//

import UIKit

import Alamofire
import SwiftyJSON
import KeychainSwift

class LoginController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: Properties
    
    let keychain = KeychainSwift()
    
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
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.login(loginId: id, passsword: password))
            .responseJSON { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    
                    //Token : Dictionary To String
                    
                    let tokens = String((response.response?.headers.dictionary["Authorization"] ?? ""))
                    let splitToken = tokens.components(separatedBy: ",")
                    
                    let refreshStartIndex = splitToken[0].index(splitToken[0].startIndex,
                                                                offsetBy: 14)
                    let refreshToken = String(splitToken[0][refreshStartIndex...])
    
                    let accessStartIndex = splitToken[1].index(splitToken[1].startIndex,
                                                               offsetBy: 13)
                    var accessToken = String(splitToken[1].dropLast())
                    accessToken = String(accessToken[accessStartIndex...])

                    //Keychain Setting
                    
                    self.keychain.clear()
                    self.keychain.set(accessToken, forKey: "AccessToken")
                    self.keychain.set(refreshToken, forKey: "RefreshToken")
                    
                    
                    
                    
                }
                
                
//                print("Refresh - \(splitToken[0])")
//                print("Access - \(splitToken[1])")
              
        }
    }
    
    //MARK: Design Functions
    
}
