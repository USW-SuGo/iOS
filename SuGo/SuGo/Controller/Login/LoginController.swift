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

class LoginController: UIViewController, UITextFieldDelegate {

    //MARK: IBOutlets
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var idBox: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordBox: UIView!
    @IBOutlet weak var wrongAccountBox: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: Properties
    
    let keychain = KeychainSwift()
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
    //MARK: Fucntions
    
    override func viewDidLoad() {
        self.idTextField.delegate = self
        self.passwordTextField.delegate = self
        
        super.viewDidLoad()
        wrongAccountBox.isHidden = true
        designBox()
        idTextField.addTarget(self,
                              action: #selector(idBoxClicked),
                              for: .touchDown)
        idTextField.addTarget(self,
                              action: #selector(idBoxClicked),
                              for: .editingChanged)
        passwordTextField.addTarget(self,
                                    action: #selector(passwordBoxClicked),
                                    for: .touchDown)
        passwordTextField.addTarget(self,
                                    action: #selector(passwordBoxClicked),
                                    for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    

    
    //MARK: Button Actions

    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
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
                    
                    self.dismiss(animated: true)
                // 로그인 실패한 경우 에러 메세지 출력
                } else {
                    
                    self.failToLogin()
                    
                }
                
                
//                print("Refresh - \(splitToken[0])")
//                print("Access - \(splitToken[1])")
              
        }
    }
    
    //MARK: Design Functions
    
    @objc func idBoxClicked(_ sender: UITextField) {
        wrongAccountBox.isHidden = true
        idBox.layer.borderColor = colorLiteralGreen.cgColor
        passwordBox.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    @objc func passwordBoxClicked(_ sender: UITextField) {
        wrongAccountBox.isHidden = true
        idBox.layer.borderColor = UIColor.lightGray.cgColor
        passwordBox.layer.borderColor = colorLiteralGreen.cgColor
        
    }
    
    func failToLogin() {
        idBox.layer.borderColor = UIColor.red.cgColor
        passwordBox.layer.borderColor = UIColor.red.cgColor
        wrongAccountBox.isHidden = false
    }
    
    func designBox() {
        
        idBox.layer.borderWidth = 0.5
        idBox.layer.cornerRadius = 6.0
        idBox.layer.borderColor = UIColor.lightGray.cgColor
        
        passwordBox.layer.borderWidth = 0.5
        passwordBox.layer.cornerRadius = 6.0
        passwordBox.layer.borderColor = UIColor.lightGray.cgColor
        
        loginButton.layer.borderColor = colorLiteralGreen.cgColor
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.cornerRadius = 6.0
        
    }
    
}
