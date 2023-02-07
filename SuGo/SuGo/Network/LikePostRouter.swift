//
//  LikePostRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/07.
//

import Foundation

import Alamofire
import KeychainSwift

enum LikePostRouter: URLRequestConvertible {
        
  case likePost(productIndex: Int)
  case getLikePost(page: Int, size: Int)

  var baseURL: URL {
    return URL(string: API.BASE_URL + "/like-post")!
  }

  var method: HTTPMethod {
    switch self {
    case .likePost:
      return .post
    case .getLikePost:
      return .get
    }
  }

  var path: String {
    switch self {
    case .likePost, .getLikePost:
      return ""
    }
  }
    
  var parameters: Parameters {
      switch self {
      case .likePost(let productIndex):
        return ["productPostId" : productIndex]
      case .getLikePost(let page, let size):
        return [
          "page" : page,
          "size" : size
        ]
      }
  }
    
    var headers: HTTPHeaders {
      switch self{
      case .likePost, .getLikePost:
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
    if request.method == .post || request.method == .delete {
      request = try JSONEncoding.default.encode(request, with: parameters)
    } else if request.method == .get {
      request = try URLEncoding.default.encode(request, with: parameters)
    }

    return request
  }
    
}
