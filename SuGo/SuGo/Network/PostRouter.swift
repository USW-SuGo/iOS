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
    
    case getDetailPost(productPostId: Int)
    
    
    
    var baseURL: URL {
        return URL(string: API.BASE_URL + "/post")!
    }
    
    var method: HTTPMethod {
        switch self {
        case .postContent:
            return .post
        case .mainPage, .getDetailPost:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .postContent:
            return "/content"
        case .mainPage:
            return "/all"
        case .getDetailPost:
            return "/"
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
        
        case .getDetailPost(let productPostId):
            return ["productPostId" : productPostId]
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .postContent, .getDetailPost:
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
        
        if request.method == .post {
            request = try JSONEncoding.default.encode(request, with: parameters)
        } else if request.method == .get {
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
}
