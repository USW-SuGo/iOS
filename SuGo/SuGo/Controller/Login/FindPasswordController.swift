//
//  FindPasswordController.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/18.
//

import UIKit

import Alamofire
import SwiftyJSON

class FindPasswordController: UIViewController {
  
  //MARK: IBOutlets
  
  @IBOutlet weak var idTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var idBottomLine: UIView!
  @IBOutlet weak var emailBottomLine: UIView!
  @IBOutlet weak var sendEmailButton: UIButton!
  
  //MARK: Properties
  
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  
  //MARK: Life-Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    buttonDesign()
    idTextField.addTarget(self, action: #selector(idTextFieldClicked), for: .touchDown)
    emailTextField.addTarget(self, action: #selector(emailTextFieldClicked), for: .touchDown)
  }
  
  //MARK: Button Actions
  
  @IBAction func sendEmailButtonClicked(_ sender: Any) {
    guard let id = idTextField.text, !id.isEmpty else {
      customAlert(title: "아이디를 입력해주세요.",
                  message: "아이디가 입력되지 않았습니다.",
                  statusCode: 400)
      return }
    guard let email = emailTextField.text, !email.isEmpty else {
      customAlert(title: "이메일을 입력해주세요.",
                  message: "이메일이 입력되지 않았습니다.",
                  statusCode: 400)
      return }
    
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.findPassword(loginId: id, email: email))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          self.customAlert(title: "입력 정보를 확인하세요.",
                           message: "확인 되지 않은 계정입니다.",
                           statusCode: response.response?.statusCode ?? 400)
          return
        }
        self.customAlert(title: "이메일을 확인하세요!",
                         message: "이메일로 임시 비밀번호를 발송했습니다.",
                         statusCode: statusCode)
      }
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    self.dismiss(animated: true)
  }
  
  
  //MARK: Design Functions
  
  @objc func idTextFieldClicked(_ sender: UITextField) {
    idBottomLine.layer.backgroundColor = colorLiteralGreen.cgColor
    emailBottomLine.layer.backgroundColor = UIColor.lightGray.cgColor
  }
  
  @objc func emailTextFieldClicked(_ sender: UITextField) {
    idBottomLine.layer.backgroundColor = UIColor.lightGray.cgColor
    emailBottomLine.layer.backgroundColor = colorLiteralGreen.cgColor
  }
  
  private func buttonDesign() {
    sendEmailButton.layer.cornerRadius = 6.0
    sendEmailButton.layer.borderWidth = 0.5
    sendEmailButton.layer.borderColor = UIColor.white.cgColor
  }
  
  private func customAlert(title: String, message: String, statusCode: Int) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { alert in
      guard statusCode == 200 else {
        return
      }
      self.dismiss(animated: true)
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
}
