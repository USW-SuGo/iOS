//
//  SearchRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation
import Alamofire

enum LoginRouter: URLRequestConvertible {
        
  case checkEmail(email: String)
  case checkLoginId(id: String)
  case join(loginId: String, email: String, password: String, department: String)
  case login(loginId: String, passsword: String)
  case checkAuthNumber(userId: Int, payload: String)
  
  var baseURL: URL {
    return URL(string: API.BASE_URL + "/user")!
  }

  var method: HTTPMethod {
    switch self {
    case .checkEmail, .checkLoginId, .join, .login, .checkAuthNumber:
      return .post
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
    }
  }
  
  var parameters: Parameters {
    switch self {
    case let .checkEmail(email):
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
    }
  }
  
  var headers: HTTPHeaders {
    switch self{
    case .checkEmail, .checkLoginId, .join, .login, .checkAuthNumber:
      return [
          .contentType("application/json"),
          .accept("application/json")
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
