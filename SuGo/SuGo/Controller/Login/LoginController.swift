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
  @IBOutlet weak var idLabel: UILabel!
  @IBOutlet weak var passwordLabel: UILabel!
  @IBOutlet weak var signUpButton: UIButton!
  
  //MARK: Properties
    
    let keychain = KeychainSwift()
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
    //MARK: Fucntions
    
  override func viewDidLoad() {
    idTextField.delegate = self
    passwordTextField.delegate = self
    passwordTextField.isSecureTextEntry = true
    super.viewDidLoad()
    wrongAccountBox.isHidden = true
    designBox()
    keyboardTopToolBar()
    textFieldsAddTargets()
  }
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
  }
  
  private func textFieldsAddTargets() {
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
  }

    
  //MARK: Button Actions
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    self.dismiss(animated: true)
  }
  
  @IBAction func findIdButtonClicked(_ sender: Any) {
    let findIdViewStoryboard = UIStoryboard(name: "FindIdView", bundle: nil)
    let findIdController = findIdViewStoryboard.instantiateViewController(withIdentifier: "findIdVC")
    self.present(findIdController, animated: true, completion: nil)
  }
  
  @IBAction func findPasswordButtonClicked(_ sender: Any) {
    let findPasswordViewStorybard = UIStoryboard(name: "FindPasswordView", bundle: nil)
    let findPasswordController = findPasswordViewStorybard.instantiateViewController(withIdentifier: "findPasswordVC")
    self.present(findPasswordController, animated: true)
  }
  
  @IBAction func signUpButtonClicked(_ sender: Any) {
        
      let signUpViewStoryboard = UIStoryboard(name: "SignUpView", bundle: nil)
      guard let nextViewController = signUpViewStoryboard.instantiateViewController(withIdentifier: "signUpNavigationVC") as? UINavigationController else { return }
      nextViewController.modalPresentationStyle = .fullScreen
      self.present(nextViewController, animated: true, completion: nil)
      
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.login(loginId: id, passsword: password))
            .response { response in
                
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                  
                  //Token : Dictionary To String
                  
                  let tokens = String((response.response?.headers.dictionary["Authorization"] ?? ""))
                  print("tokens - \(tokens)")
                  let splitToken = tokens.components(separatedBy: ",")
                  print("splitToken - \(splitToken)")
                  let refreshStartIndex = splitToken[0].index(splitToken[0].startIndex,
                                                              offsetBy: 14)
                  let refreshToken = String(splitToken[0][refreshStartIndex...])
                  let accessStartIndex = splitToken[1].index(splitToken[1].startIndex,
                                                             offsetBy: 13)
                  var accessToken = String(splitToken[1].dropLast())
                  accessToken = String(accessToken[accessStartIndex...])

                  //Keychain Setting
                  print("accessToken - \(accessToken)")
                  print("refreshToken - \(refreshToken)")
                  self.keychain.set(accessToken, forKey: "AccessToken")
                  self.keychain.set(refreshToken, forKey: "RefreshToken")
                  self.dismiss(animated: true)
                
                // 로그인 실패한 경우 에러 메세지 출력
              } else {
                  self.failToLogin()
            }
          }
        }
    
    //MARK: Design Functions
  
  func keyboardTopToolBar() {
    let toolbar = UIToolbar()
    let doneBtn = UIBarButtonItem(barButtonSystemItem: .done,
                                  target: nil,
                                  action: #selector(doneButtonClicked))
//    let customBtn = UIBarButtonItem(title: "button", style: .plain, target: nil, action: nil)
    // 여백
    let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                              target: nil,
                                              action: nil)
    toolbar.sizeToFit()
    toolbar.setItems([flexibleSpaceButton, flexibleSpaceButton, doneBtn], animated: false)
    idTextField.inputAccessoryView = toolbar
    passwordTextField.inputAccessoryView = toolbar
  }
  
  @objc func doneButtonClicked() {
    self.view.endEditing(true)
  }
    
  @objc func idBoxClicked(_ sender: UITextField) {
    wrongAccountBox.isHidden = true
    idLabel.textColor = .black
    passwordLabel.textColor = .black
    idBox.layer.borderColor = colorLiteralGreen.cgColor
    passwordBox.layer.borderColor = UIColor.lightGray.cgColor
      
  }

  @objc func passwordBoxClicked(_ sender: UITextField) {
    wrongAccountBox.isHidden = true
    idLabel.textColor = .black
    passwordLabel.textColor = .black
    idBox.layer.borderColor = UIColor.lightGray.cgColor
    passwordBox.layer.borderColor = colorLiteralGreen.cgColor
  }
  
  func failToLogin() {
    idBox.layer.borderColor = UIColor.red.cgColor
    passwordBox.layer.borderColor = UIColor.red.cgColor
    idLabel.textColor = .red
    passwordLabel.textColor = .red
    wrongAccountBox.isHidden = false
  }
  
  func designBox() {
    signUpButton.layer.cornerRadius = 6.0
    signUpButton.layer.borderWidth = 0.7
    signUpButton.layer.borderColor = colorLiteralGreen.cgColor
    
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
