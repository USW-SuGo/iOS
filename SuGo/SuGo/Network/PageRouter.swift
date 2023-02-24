//
//  PageRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/07.
//

import Foundation

import Alamofire
import KeychainSwift

enum PageRouter: URLRequestConvertible {
        
  case myPage
  case userPage(userId: Int)
  case userMannerEvaluate(userId: Int, grade: Double)

  var baseURL: URL {
      return URL(string: API.BASE_URL + "/user")!
  }

  var method: HTTPMethod {
      switch self {
      case .myPage, .userPage:
        return .get
      case .userMannerEvaluate:
        return .post
      }
  }

  var path: String {
    switch self {
    case .myPage:
      return ""
    case .userPage(let userId):
      return "/\(userId)/"
    case .userMannerEvaluate:
      return "/manner"
    }
  }
  
  var parameters: Parameters {
    switch self {
    case .myPage, .userPage : return [:]
    case .userMannerEvaluate(let userId, let grade):
      return [
        "targetUserId" : userId,
        "grade" : grade
      ]
    }
  }
  
  var headers: HTTPHeaders {
    switch self{
    case .myPage, .userPage, .userMannerEvaluate:
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
    
    if request.method == .post {
      request = try JSONEncoding.default.encode(request, with: parameters)
    } else if request.method == .get {
      request = try URLEncoding.default.encode(request, with: parameters)
    }
    
    return request
  }
  
}
