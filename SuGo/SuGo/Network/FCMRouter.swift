//
//  FCMRouter.swift
//  SuGo
//
//  Created by 한지석 on 2023/03/07.
//

import Foundation

import Alamofire
import KeychainSwift

enum FCMRouter: URLRequestConvertible {

  case sendFCM(token: String)

  var baseURL: URL {
      return URL(string: API.BASE_URL)!
  }

  var method: HTTPMethod {
      switch self {
      case .sendFCM:
        return .post
      }
  }

  var path: String {
      switch self {
      case .sendFCM:
        return "/fcm"
      }
  }

  var parameters: Parameters {
    switch self {
    case .sendFCM(let token):
      return ["fcmToken" : token]
    }
  }

  var headers: HTTPHeaders {
      switch self{
      case .sendFCM:
          return [
              .authorization(String(KeychainSwift().get("AccessToken") ?? ""))
          ]
      }
  }

  func asURLRequest() throws -> URLRequest {
    let url = baseURL.appendingPathComponent(path) // string을 붙히는, path를 이어 붙힌다.
    
    var request = URLRequest(url: url)

    request.method = method
    request.headers = headers
    request = try JSONEncoding.default.encode(request, with: parameters)

    return request
  }


}
