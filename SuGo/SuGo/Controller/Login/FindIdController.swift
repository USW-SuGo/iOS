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
  
  @IBOutlet weak var emailTextField: UITextField!
  
  //MARK: Life-Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  @IBAction func sendEmailButtonClicked(_ sender: Any) {
    guard let email = emailTextField.text, !email.isEmpty else { return }
    
    AlamofireManager
      .shared
      .session
      .request(LoginRouter.findId(email: email))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        print(JSON(response.data))
      }
  }
  
}

