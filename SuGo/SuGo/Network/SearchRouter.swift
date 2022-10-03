//
//  SearchRouter.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation
import Alamofire

enum SearchRouter: URLRequestConvertible {
        
    case get(term: String)
    case post(term: String)

    var baseURL: URL {
        return URL(string: API.BASE_URL)!
    }

    var method: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        }
    }

    var path: String {
        switch self {
        case .get:
            return "get"
        case .post:
            return "post"
        }
    }

    func asURLRequest() throws -> URLRequest {
        
        print("SearchRouter - asURLRequest() called")
        
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        
        return request
    }
    
    
}
