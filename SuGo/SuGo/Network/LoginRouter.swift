//
//  SearchRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation

import Alamofire
import KeychainSwift

enum LoginRouter: URLRequestConvertible {
        
  case checkEmail(email: String)
  case checkLoginId(id: String)
  case join(loginId: String, email: String, password: String, department: String)
  case login(loginId: String, passsword: String)
  case checkAuthNumber(userId: Int, payload: String)
  case findId(email: String)
  case findPassword(loginId: String, email: String)
  case changePassword(prePassword: String, newPassword: String)
  case deleteAccount(loginId: String, email: String, password: String)
  
  var baseURL: URL {
    return URL(string: API.BASE_URL + "/user")!
  }

  var method: HTTPMethod {
    switch self {
    case .checkEmail, .checkLoginId, .join, .login, .checkAuthNumber, .findId, .findPassword:
      return .post
    case .changePassword:
      return .put
    case .deleteAccount:
      return .delete
    }
  }

  var path: String {
    switch self {
    case .checkEmail:
      return "/check-email"
    case .checkLoginId:
      return "/check-loginId"
    case .join:
      return "/join"
    case .login:
      return "/login"
    case .checkAuthNumber:
      return "/auth"
    case .findId:
      return "/find-id"
    case .findPassword:
      return "/find-pw"
    case .changePassword:
      return "/password"
    case .deleteAccount:
      return ""
    }
  }
  
  var parameters: Parameters {
    switch self {
    case let .checkEmail(email), let .findId(email):
      return ["email" : email]
      
    case let .checkLoginId(id):
      return ["loginId" : id]
      
    case .join(let loginId, let email, let password, let department):
      return [
        "loginId" : loginId,
        "email" : email,
        "password" : password,
        "department" : department
      ]
      
    case .login(let loginId, let password):
      return [
        "loginId" : loginId,
        "password" : password
      ]
      
    case .checkAuthNumber(let userId, let payload):
      return [
        "userId" : userId,
        "payload" : payload
      ]
      
    case .findPassword(let loginId, let email):
      return [
        "loginId" : loginId,
        "email" : email
      ]
    case .changePassword(let prePassword, let newPassword):
      return [
        "prePassword" : prePassword,
        "newPassword" : newPassword
      ]
    case .deleteAccount(let loginId, let email, let password):
      return [
        "loginId" : loginId,
        "email" : email,
        "password" : password
      ]
    }
  }
  
  var headers: HTTPHeaders {
    switch self{
    case .checkEmail, .checkLoginId, .join, .login, .checkAuthNumber,
        .findId, .findPassword:
      return [
          .contentType("application/json"),
          .accept("application/json")
      ]
    case .changePassword, .deleteAccount:
      return [
        .authorization(String(KeychainSwift().get("AccessToken") ?? ""))
      ]
    }
  }
  
  
  func asURLRequest() throws -> URLRequest {
      
    let url = baseURL.appendingPathComponent(path) // string을 붙히는, path를 이어 붙힌다.
    
    print("LoginRouter - asURLRequest() url : \(url)")
    
    var request = URLRequest(url: url)
    
    request.method = method
    request.headers = headers
    request = try JSONEncoding.default.encode(request, with: parameters)

    return request
  }
  
  
}
