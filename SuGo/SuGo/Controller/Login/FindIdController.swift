//
//  FindIDController.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/18.
//

import UIKit

import Alamofire
import SwiftyJSON

class FindIdController: UIViewController {
  
  //MARK: IBOutlets
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var emailBottomLine: UIView!
  @IBOutlet weak var sendEmailButton: UIButton!
  
  //MARK: Properties
  
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  
  //MARK: Life-Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    emailTextField.addTarget(self, action: #selector(emailTextFieldClicked), for: .touchDown)
    buttonDesign()
    // Do any additional setup after loading the view.
  }
  
  //MARK: Functions
  
  //MARK: Button Actions
  
  @IBAction func sendEmailButtonClicked(_ sender: Any) {
    guard let email = emailTextField.text, !email.isEmpty else {
      customAlert(title: "이메일을 입력해 주세요.",
                  message: "이메일이 입력되지 않았습니다.",
                  statusCode: 400)
      return }
    
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.findId(email: email))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          self.customAlert(title: "존재하지 않는 계정 정보입니다.",
                           message: "이메일을 다시 확인해 주세요!",
                           statusCode: response.response?.statusCode ?? 400)
          return }
        self.customAlert(title: "이메일로 아이디를 전송했습니다.",
                         message: "이메일을 확인해 주세요!",
                         statusCode: statusCode)
      }
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    self.dismiss(animated: true)
  }
  
  //MARK: Design Functions
  
  private func buttonDesign() {
    sendEmailButton.layer.cornerRadius = 6.0
    sendEmailButton.layer.borderWidth = 0.5
    sendEmailButton.layer.borderColor = UIColor.white.cgColor
  }
  
  @objc func emailTextFieldClicked(_ sender: UITextField) {
    emailBottomLine.layer.backgroundColor = colorLiteralGreen.cgColor
  }
  
  private func customAlert(title: String, message: String, statusCode: Int) {
    print(statusCode)
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

