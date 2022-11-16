//
//  EmailAuthController.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/10.
//

import UIKit

import Alamofire
import SwiftyJSON

class EmailAuthController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var emailAuthBox: UIView!
  @IBOutlet weak var emailAuthTextField: UITextField!
  @IBOutlet weak var portalButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  
  //MARK: Properties

  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let userInfo = UserInfo.shared
  
  //MARK: Life Cycle
  
//  override func loadView() {
//    let webConfiguration = WKWebViewConfiguration()
//    webView = WKWebView(frame: .zero, configuration: webConfiguration)
//    webView.uiDelegate = self
//    view = webView
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    designIBOutlets()
  }
  
  //MARK: Functions
  
  //MARK: Button Actions
  
  @IBAction func portalButtonClicked(_ sender: Any) {
    let portalView = UIStoryboard(name: "PortalView", bundle: nil)
    let portalController = portalView.instantiateViewController(withIdentifier: "portalVC")
    present(portalController, animated: true)
  }
  
  @IBAction func signUpButtonClicked(_ sender: Any) {
    guard let userIndex = userInfo.userIndex else { return }
    guard let payload = emailAuthTextField.text else { return }
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.checkAuthNumber(userId: userIndex, payload: payload))
      .validate()
      .responseJSON { response in
        
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          self.customAlert(title: "인증번호가 일치하지 않아요!", message: "다시 입력해주세요!")
          return
        }
        self.customAlert(title: "회원가입에 성공했어요!", message: "오늘도 수고하세요!")
        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
      }
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    customAlertWithHandler(title: "회원가입을 종료하시겠어요?", message: "종료하게 될 경우, 한 시간 뒤에 동일 계정으로 가입이 가능합니다.")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
  }
  
  //MARK: Design Functions
  
  private func designIBOutlets() {
    emailAuthBox.layer.cornerRadius = 3.0
    emailAuthBox.layer.borderWidth = 0.7
    emailAuthBox.layer.borderColor = UIColor.lightGray.cgColor
    
    signUpButton.layer.cornerRadius = 6.0
    
    portalButton.layer.cornerRadius = 6.0
    portalButton.layer.borderColor = colorLiteralGreen.cgColor
    portalButton.layer.borderWidth = 0.5
  }
  
  private func customAlertWithHandler(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { UIAlertAction in
      self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }))
    alert.addAction(UIAlertAction(title: "취소", style: .destructive))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
    
}


