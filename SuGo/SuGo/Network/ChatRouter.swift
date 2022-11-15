//
//  ChatRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/15.
//

import Foundation

import Alamofire
import KeychainSwift

enum ChatRouter: URLRequestConvertible {
        
  case chatList(roomIndex: Int,
                oppositeIndex: Int,
                oppositeNickname: String,
                recentChat: String,
                recentChatTime: String)

  var baseURL: URL {
      return URL(string: API.BASE_URL + "/note")!
  }

  var method: HTTPMethod {
      switch self {
      case .chatList:
          return .get
          
      }
  }

  var path: String {
      switch self {
      case .chatList:
          return "/list"
      }
  }
  
//  var parameters: Parameters {
//      switch self {
//
//      case .chatList(let roomIndex,
//                     let oppositeIndex,
//                     let oppositeNickname,
//                     let recentChat,
//                     let recentChatTime)
//
//          return [
//              "roomIndex" : roomIndex,
//              "oppositeIndex" : oppositeIndex,
//              "" : oppositeNickname,
//              "" : recentChat,
//              ""
//          ]
//
//      }
//  }
  
  var headers: HTTPHeaders {
      switch self{
      case .chatList:
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
    request = try URLEncoding.default.encode(request, with: nil)

    return request
  }
    
    
}
