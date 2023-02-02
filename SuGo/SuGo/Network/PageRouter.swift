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
        
    case myPage(page: Int, size: Int)
    case userPage(userId: Int, page: Int, size: Int)

    var baseURL: URL {
        return URL(string: API.BASE_URL)!
    }

    var method: HTTPMethod {
        switch self {
        case .myPage, .userPage:
            return .get
            
        }
    }

    var path: String {
        switch self {
        case .myPage:
            return "/user"
        case .userPage:
            return "/user/"
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .myPage(let page, let size):
            return [
                "page" : page,
                "size" : size
            ]
        case .userPage(let userId, let page, let size):
            return [
                "userId" : userId,
                "page" : page,
                "size" : size
            ]
        }
    }
    
    var headers: HTTPHeaders {
        switch self{
        case .myPage, .userPage:
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
        request = try URLEncoding.default.encode(request, with: parameters)
    
        return request
    }
    
    
}
