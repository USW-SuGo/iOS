//
//  SignUpController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/10.
//

import UIKit

import Alamofire
import SwiftyJSON
import IQKeyboardManagerSwift

// 회원가입 로직
// 1. 아이디 형식 확인 및 중복확인
// 2. 비밀번호 형식 확인
// 3. 2차 비밀번호 일치 판별
// 4. 이메일 중복 확인
// 5. 완료와 동시에 인증메일 전송
// 텍스트 변경을 실시간으로 확인해주어야 함. 예를 들어 이메일 중복확인 이후 텍스트가 변경되는 경우를 캐치 해야 함.
// 이후 signUpView 하단에 약관 동의 체크박스 추가

class SignUpController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var idTextField: UITextField!
  @IBOutlet weak var idBox: UIView!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordBox: UIView!
  @IBOutlet weak var confirmPasswordTextField: UITextField!
  @IBOutlet weak var confirmPasswordBox: UIView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var emailBox: UIView!
  @IBOutlet weak var idWarningLabel: UILabel!
  @IBOutlet weak var passwordWarningLabel: UILabel!
  @IBOutlet weak var confirmPasswordWarningLabel: UILabel!
  @IBOutlet weak var emailWarningLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  
  //MARK: Properties
  
  let loginModel = LoginModel()
  
  var emailIsValid = false
  var idIsValid = false
  var passwordIsValid = false
  var confirmPasswordIsValid = false
  var signUpIsValid: Bool {
      return emailIsValid && idIsValid && passwordIsValid && confirmPasswordIsValid
  }
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let userInfo = UserInfo.shared
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    textFieldDelegates()
    customBackButton()
    customRightBarButton()
    designBox()
    hiddenLabels()
    textFieldAddTargets()
    super.viewDidLoad()
  }
  
  //MARK: Functions
  
  private func textFieldDelegates() {
    emailTextField.delegate = self
    idTextField.delegate = self
    passwordTextField.delegate = self
    confirmPasswordTextField.delegate = self
  }

  // 텍스트필드에 action 추가
  private func textFieldAddTargets() {
    emailTextField.addTarget(self,
                             action: #selector(emailTextFieldEditingChanged),
                             for: .touchDown)
    emailTextField.addTarget(self,
                             action: #selector(emailTextFieldEditingChanged),
                             for: .editingChanged)
    emailTextField.addTarget(self,
                             action: #selector(emailTextFieldisValid),
                             for: .editingDidEnd)
    idTextField.addTarget(self,
                          action: #selector(idTextFieldEditingChanged),
                          for: .touchDown)
    idTextField.addTarget(self,
                          action: #selector(idTextFieldEditingChanged),
                          for: .editingChanged)
    idTextField.addTarget(self,
                          action: #selector(idTextFieldisValid),
                          for: .editingDidEnd)
    passwordTextField.addTarget(self,
                                action: #selector(passwordTextFieldEditingChanged),
                                for: .touchDown)
    passwordTextField.addTarget(self,
                                action: #selector(passwordTextFieldEditingChanged),
                                for: .editingChanged)
    passwordTextField.addTarget(self,
                                action: #selector(passwordTextFieldisValid),
                                for: .editingDidEnd)
    passwordTextField.isSecureTextEntry = true
    confirmPasswordTextField.addTarget(self,
                                       action: #selector(confirmPasswordTextFieldEditingChanged),
                                       for: .touchDown)
    confirmPasswordTextField.addTarget(self,
                                       action: #selector(confirmPasswordTextFieldEditingChanged),
                                       for: .editingChanged)
    confirmPasswordTextField.addTarget(self,
                                       action: #selector(confirmPasswordTextFieldisValid),
                                       for: .editingChanged)
    confirmPasswordTextField.addTarget(self,
                                       action: #selector(confirmPasswordTextFieldisValid),
                                       for: .editingDidEnd)
    confirmPasswordTextField.isSecureTextEntry = true
    
  }
  
  // 기존 입력마다 형식 알려주던 방식 대신, endEditing 이후 유효성 검사하는 방식으로 전환
  
  @objc func emailTextFieldEditingChanged(_ sender: UITextField) {
      emailBox.layer.borderColor = colorLiteralGreen.cgColor
      idBox.layer.borderColor = UIColor.lightGray.cgColor
      passwordBox.layer.borderColor = UIColor.lightGray.cgColor
      confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
  }
  

  @objc func emailTextFieldisValid(_ sender: UITextField) {
    emailWarningLabel.isHidden = false
    guard let email = emailTextField.text, !email.isEmpty else { return }
    guard loginModel.isValidEmail(email: email) else {
      warningText(label: emailWarningLabel,
                  box: emailBox,
                  text: "이메일 형식이 올바르지 않아요.",
                  textColor: UIColor.red,
                  borderColor: UIColor.red.cgColor,
                  validType: &emailIsValid,
                  bool: false)
      return
    }
    emailOverlapCheck(email: email + "@suwon.ac.kr")
  }
  
  @objc func idTextFieldEditingChanged(_ sender: UITextField) {
    emailBox.layer.borderColor = UIColor.lightGray.cgColor
    idBox.layer.borderColor = colorLiteralGreen.cgColor
    passwordBox.layer.borderColor = UIColor.lightGray.cgColor
    confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
  }
  
  @objc func idTextFieldisValid(_ sender: UITextField) { // id 정규표현식 확인
    idWarningLabel.isHidden = false
    guard let id = idTextField.text, !id.isEmpty else { return }
    
    //1. 아이디 형식 체크 후 일치하지 않을 경우 경고문 ON
    guard loginModel.isValidId(id: id) else {
      warningText(label: idWarningLabel,
                  box: idBox,
                  text: "영문/숫자를 사용한 5~20자 아이디를 사용해주세요.",
                  textColor: UIColor.red,
                  borderColor: UIColor.red.cgColor,
                  validType: &idIsValid,
                  bool: false)
      return
    }
    idOverlapCheck(id: id)
  }
  
  @objc func passwordTextFieldEditingChanged(_ sender: UITextField) {
    emailBox.layer.borderColor = UIColor.lightGray.cgColor
    idBox.layer.borderColor = UIColor.lightGray.cgColor
    passwordBox.layer.borderColor = colorLiteralGreen.cgColor
    confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
  }
  
  @objc func passwordTextFieldisValid(_ sender: UITextField) { // password 정규표현식
    passwordWarningLabel.isHidden = false
    
    guard let password = passwordTextField.text, !password.isEmpty else { return }
    guard loginModel.isValidPassword(pwd: password) else {
      warningText(label: passwordWarningLabel,
                  box: passwordBox,
                  text: "영문/숫자/특수문자를 조합한 8~20자 비밀번호를 사용해주세요.",
                  textColor: UIColor.red,
                  borderColor: UIColor.red.cgColor,
                  validType: &passwordIsValid,
                  bool: false)
      return
    }
    guard let count = confirmPasswordTextField.text?.count,
              count > 0,
              password == confirmPasswordTextField.text else {
      warningText(label: confirmPasswordWarningLabel,
                  box: confirmPasswordBox,
                  text: "비밀번호가 일치하지 않아요.",
                  textColor: UIColor.red,
                  borderColor: UIColor.red.cgColor,
                  validType: &confirmPasswordIsValid,
                  bool: false)
      return
    }

    warningText(label: passwordWarningLabel,
                box: passwordBox,
                text: "사용 가능한 비밀번호에요!",
                textColor: colorLiteralGreen,
                borderColor: colorLiteralGreen.cgColor,
                validType: &passwordIsValid,
                bool: true)
  }
  
  @objc func confirmPasswordTextFieldEditingChanged(_ sender: UITextField) {
      emailBox.layer.borderColor = UIColor.lightGray.cgColor
      idBox.layer.borderColor = UIColor.lightGray.cgColor
      passwordBox.layer.borderColor = UIColor.lightGray.cgColor
      confirmPasswordBox.layer.borderColor = colorLiteralGreen.cgColor
  }
  
  @objc func confirmPasswordTextFieldisValid(_ sender: UITextField) {
    confirmPasswordWarningLabel.isHidden = false
      
    guard let password = confirmPasswordTextField.text, !password.isEmpty else { return }
    guard password == passwordTextField.text else {
      warningText(label: confirmPasswordWarningLabel,
                  box: confirmPasswordBox,
                  text: "비밀번호가 일치하지 않아요.",
                  textColor: UIColor.red,
                  borderColor: UIColor.red.cgColor,
                  validType: &confirmPasswordIsValid,
                  bool: false)
      return
    }
    
    warningText(label: confirmPasswordWarningLabel,
                box: confirmPasswordBox,
                text: "비밀번호가 일치해요!",
                textColor: colorLiteralGreen,
                borderColor: colorLiteralGreen.cgColor,
                validType: &confirmPasswordIsValid,
                bool: true)
  }
  
  @objc func closeButtonClicked() {
    self.dismiss(animated: true)
  }
  
  /* IQKeyboard 라이브러리 사용으로 대체
  @objc func keyboardWillAppear(_ notification: NSNotification){
    if keyboardTouchCheck == false && emailTouch == false{
      keyboardTouchCheck = true
      if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        UIView.animate(withDuration: 0.7){
          self.view.frame.origin.y -= 180
        }
      }
    }
  }
  
  @objc func keyboardWillDisappear(_ notification: Notification){
    if keyboardTouchCheck == true{
      keyboardTouchCheck = false
      UIView.animate(withDuration: 0.8){
        self.view.frame.origin.y = 0
      }
    }
  }
  */
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
  }
  
  //MARK: API Functions
  
  func emailOverlapCheck(email: String) {
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.checkEmail(email: email))
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          return
        }
        guard let data = response.data else { return }
        guard JSON(data)["exist"].boolValue else {
          self.warningText(label: self.emailWarningLabel,
                           box: self.emailBox,
                           text: "이미 사용중이거나, 사용할 수 없는 이메일이에요.",
                           textColor: UIColor.red,
                           borderColor: UIColor.red.cgColor,
                           validType: &self.emailIsValid,
                           bool: false)
          return
        }
        self.warningText(label: self.emailWarningLabel,
                         box: self.emailBox,
                         text: "사용 가능한 이메일이에요!",
                         textColor: self.colorLiteralGreen,
                         borderColor: self.colorLiteralGreen.cgColor,
                         validType: &self.emailIsValid,
                         bool: true)
    }
  }
  
  func idOverlapCheck(id: String) {
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.checkLoginId(id: id))
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        guard let data = response.data else { return }
        guard JSON(data)["exist"].boolValue else {
          self.warningText(label: self.idWarningLabel,
                           box: self.idBox,
                           text: "이미 사용중인 아이디에요!",
                           textColor: UIColor.red,
                           borderColor: UIColor.red.cgColor,
                           validType: &self.idIsValid,
                           bool: false)
          return
        }
        self.idIsValid = true
        self.warningText(label: self.idWarningLabel,
                         box: self.idBox,
                         text: "사용 가능한 아이디에요!",
                         textColor: self.colorLiteralGreen,
                         borderColor: self.colorLiteralGreen.cgColor,
                         validType: &self.idIsValid,
                         bool: true)
    }
  }
  
  private func typeIsValid(validType: inout Bool, bool: Bool) {
    validType = bool
  }
  
  //MARK: Button Actions
   
  @IBAction func nextButtonClicked(_ sender: Any) {
    
      if signUpIsValid {
          
        userInfo.loginId = idTextField.text
        userInfo.password = passwordTextField.text
        userInfo.email = (emailTextField.text ?? "sozohoy") + "@suwon.ac.kr"
        let departmentViewStoryboard = UIStoryboard(name: "DepartmentView", bundle: nil)
        let nextViewController =
        departmentViewStoryboard.instantiateViewController(withIdentifier: "departmentVC") as! DepartmentController
        self.navigationController?.pushViewController(nextViewController, animated: true)
          
      } else {
        customAlert(title: "계정 정보를 확인해주세요 !", message: "입력되지 않았거나, 올바르지 않은 정보가 있어요 !")
      }
  }

  //MARK: Design Funtions
  
  private func customRightBarButton() {
    let closeButton = self.navigationItem.makeSFSymbolButton(self,
                                                             action: #selector(closeButtonClicked),
                                                             symbolName: "xmark")
    self.navigationItem.rightBarButtonItem = closeButton
  }
    
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func warningText(label: UILabel,
                           box: UIView,
                           text: String,
                           textColor: UIColor,
                           borderColor: CGColor,
                           validType: inout Bool,
                           bool: Bool) {
    label.text = text
    label.textColor = textColor
    box.layer.borderColor = borderColor
    typeIsValid(validType: &validType, bool: bool)
  }
  
  func designBox() {
    emailBox.layer.borderWidth = 0.7
    emailBox.layer.borderColor = UIColor.lightGray.cgColor
    emailBox.layer.cornerRadius = 3.0
    idBox.layer.borderWidth = 0.7
    idBox.layer.borderColor = UIColor.lightGray.cgColor
    idBox.layer.cornerRadius = 3.0
    passwordBox.layer.borderWidth = 0.7
    passwordBox.layer.borderColor = UIColor.lightGray.cgColor
    passwordBox.layer.cornerRadius = 3.0
    confirmPasswordBox.layer.borderWidth = 0.7
    confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
    confirmPasswordBox.layer.cornerRadius = 3.0
    nextButton.layer.cornerRadius = 6.0
  }
  
  func hiddenLabels() {
    emailWarningLabel.isHidden = true
    idWarningLabel.isHidden = true
    passwordWarningLabel.isHidden = true
    confirmPasswordWarningLabel.isHidden = true
  }
    
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
}

extension SignUpController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case emailTextField:
      idTextField.becomeFirstResponder()
    case idTextField:
      passwordTextField.becomeFirstResponder()
    case passwordTextField:
      confirmPasswordTextField.becomeFirstResponder()
    case confirmPasswordTextField:
      confirmPasswordTextField.resignFirstResponder()
    default:
      break
    }
    return true
  }
}
