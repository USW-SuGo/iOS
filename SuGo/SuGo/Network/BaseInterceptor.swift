//
//  BaseInterceptor.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation

import Alamofire

// it will be adapt & retry
class BaseInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        print("BaseInterceptor - adapt() called")
        
        var request = urlRequest
        
        completion(.success(urlRequest))
        
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("BaseInterceptor - retry() called")
        
        completion(.doNotRetry)
    }
    
}

