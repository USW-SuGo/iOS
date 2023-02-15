//
//  PostRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/11.
//

import Foundation

import Alamofire
import KeychainSwift

enum PostRouter: URLRequestConvertible {
    
  case postContent(title: String,
                   content: String,
                   price: Int,
                   contactPlace: String,
                   category: String)
  case mainPage(page: Int,
                size: Int,
                category: String)
  case getDetailPost(productIndex: Int)
  case searchContent(value: String,
                     category: String)
  case deletePost(productIndex: Int)
  case upPost(productIndex: Int)
  case changeSaleStatus(productIndex: Int)
  case getMyPost(page: Int, size: Int)
  case getMySoldOutPost(page: Int, size: Int)
  case getUserPost(userId: Int, page: Int, size: Int)
  case getUserSoldOutPost(userId: Int, page: Int, size: Int)
    
  var baseURL: URL {
    return URL(string: API.BASE_URL + "/post")!
  }

  
  var method: HTTPMethod {
      switch self {
      case .postContent, .upPost, .changeSaleStatus:
        return .post
      case .mainPage, .searchContent, .getDetailPost, .getMyPost, .getMySoldOutPost,
          .getUserPost, .getUserSoldOutPost:
        return .get
      case .deletePost:
        return .delete
      }
  }
  
  var path: String {
    switch self {
    case .postContent:
      return "/content"
    case .mainPage:
      return "/all"
    case .getDetailPost(let productIndex):
      return "/\(productIndex)"
    case .deletePost:
      return ""
    case .searchContent:
      return "/search"
    case .upPost:
      return "/up-post"
    case .changeSaleStatus:
      return "/close"
    case .getMyPost:
      return "/my-post"
    case .getMySoldOutPost:
      return "/close-post"
    case .getUserPost(let userId, _, _):
      return "/my-post/\(userId)"
    case .getUserSoldOutPost(let userId, _, _):
      return "/close-post/\(userId)"
    }
  }
  
  var parameters: Parameters {
    switch self{
    case .postContent(let title, let content, let price, let contactPlace, let category):
      return [
        "title" : title,
        "content" : content,
        "price" : price,
        "contactPlace" : contactPlace,
        "category" : category
      ]
    case .mainPage(let page, let size, let category):
      return [
        "page" : page,
        "size" : size,
        "category" : category
      ]
    case .deletePost(let productIndex),
        .upPost(let productIndex),
        .changeSaleStatus(let productIndex):
      return ["productPostId" : productIndex]
      
    case .searchContent(let value, let category):
      return [
        "value" : value,
        "category" : category
      ]
    case .getDetailPost(_):
      return [:]
    case .getMyPost(let page, let size),
        .getMySoldOutPost(let page, let size),
        .getUserPost(_, let page, let size),
        .getUserSoldOutPost(_, let page, let size):
      return [
        "page" : page,
        "size" : size
      ]
    }
  }
    
  var headers: HTTPHeaders {
    switch self {
    case .postContent, .getDetailPost, .searchContent,
        .deletePost, .upPost, .changeSaleStatus,
        .getMyPost, .getMySoldOutPost, .getUserPost, .getUserSoldOutPost:
      return [
          .authorization(String(KeychainSwift().get("AccessToken") ?? ""))
      ]
    case .mainPage:
      return .default
    }
  }
  
  func asURLRequest() throws -> URLRequest {
          
    let url = baseURL.appendingPathComponent(path)
    
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
