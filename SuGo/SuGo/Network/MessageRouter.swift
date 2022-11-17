//
//  MessageRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/15.
//

import Foundation

import Alamofire
import KeychainSwift

enum MessageRouter: URLRequestConvertible {
        
  case messageList(page: Int,
                   size: Int)
  case makeMessageRoom(opponentIndex: Int,
                       productIndex: Int)
  case messageRoom(roomIndex: Int,
                   page: Int,
                   size: Int)
  case sendMessage(roomIndex: Int,
                   message: String,
                   myIndex: Int,
                   opponentIndex: Int)

  var baseURL: URL {
      return URL(string: API.BASE_URL + "/note")!
  }

  var method: HTTPMethod {
      switch self {
      case .makeMessageRoom, .sendMessage:
        return .post
      case .messageList, .messageRoom:
        return .get
      }
  }

  var path: String {
      switch self {
      case .messageList:
        return "/list"
      case .makeMessageRoom:
        return ""
      case .messageRoom:
        return "/"
      case .sendMessage:
        return "-content/"
      }
  }
  
  var parameters: Parameters {
    switch self {
    case .messageList(let page, let size):
      return [
        "page" : page,
        "size" : size
      ]
    case .messageRoom(let roomIndex, let page, let size):
      return [
        "noteId" : roomIndex,
        "page" : page,
        "size" : size
      ]
    case .makeMessageRoom(let opponentIndex, let productIndex):
      return [
        "opponentUserId" : opponentIndex,
        "productPostId" : productIndex
      ]
    case .sendMessage(let roomIndex, let message, let myIndex, let opponentIndex):
      return [
        "noteId" : roomIndex,
        "message" : message,
        "senderId" : myIndex,
        "receiverId" : opponentIndex
      ]
    }
  }
  
  var headers: HTTPHeaders {
      switch self{
      case .messageList, .makeMessageRoom, .messageRoom, .sendMessage:
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
