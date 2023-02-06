//
//  ChangePasswordController.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/06.
//

import UIKit

import Alamofire
import SwiftyJSON

// 새로운 비밀번호 입력 시 정규식 일치하는지 확인해야 함.
// 

class ChangePasswordController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var prePasswordTextField: UITextField!
  @IBOutlet weak var newPasswordTextField: UITextField!
  @IBOutlet weak var changePasswordButton: UIButton!
  
  //MARK: Properties
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    customButton()
    customBackButton()
      // Do any additional setup after loading the view.
  }
  
  //MARK: Functions
  
  private func changePassword(pre: String, new: String) {
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.changePassword(prePassword: pre, newPassword: new))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200
        else { print(JSON(response.data)); return }
        print(JSON(response.data))
      }
  }
 
  //MARK: Button Actions

  @IBAction func changePasswordButtonClicked(_ sender: Any) {
    guard let prePassword = prePasswordTextField.text,
          let newPassword = newPasswordTextField.text
    else { return }
    changePassword(pre: prePassword, new: newPassword)
  }
  
  //MARK: Design Functions
  
  private func customButton() {
    changePasswordButton.layer.cornerRadius = 6.0
  }
  
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
}
