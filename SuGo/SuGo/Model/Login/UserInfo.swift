//
//  UserInfo.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/25.
//

import Foundation

class UserInfo {
  
  static let shared = UserInfo()
  
  var loginId: String?
  var email: String?
  var password: String?
  var department: String?
  var userIndex: Int?
  
  private init() {}
    
}
