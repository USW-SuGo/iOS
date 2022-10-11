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
    
    var baseURL: URL {
        return URL(string: API.BASE_URL + "/post")!
    }
    
    var method: HTTPMethod {
        switch self {
        case .postContent:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .postContent:
            return "/content"
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
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .postContent:
            return [
                .authorization(String(KeychainSwift().get("AccessToken") ?? ""))
            ]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        
        request.method = method
        request.headers = headers
        request = try JSONEncoding.default.encode(request, with: parameters)
        
        return request
    }
}
