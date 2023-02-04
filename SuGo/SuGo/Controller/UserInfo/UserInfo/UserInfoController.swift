//
//  UserInfoController.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/27.
//

import UIKit

import Alamofire
import SwiftyJSON

class UserInfoController: UIViewController {

  //MARK: Properties
  
  var userId: Int?
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let userId = userId {
      getUserPage(userId: userId, page: 0, size: 10)
    }
    print("userId: \(userId ?? 1123131313)")
  }
  
  //MARK: Functions
 
  //MARK: API Functions
  
  private func getUserPage(userId: Int, page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.userPage(userId: userId, page: page, size: size))
      .validate()
      .response { response in
        print(JSON(response.data ?? ""))
      }
        
      
  }
  

}
