//
//  BaseInterceptor.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation

import Alamofire
import SwiftyJSON
import KeychainSwift

// it will be adapt & retry
class BaseInterceptor: RequestInterceptor {
    
    let keychain = KeychainSwift()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        print("BaseInterceptor - adapt() called")
        
//        var request = urlRequest
        guard urlRequest.url?.absoluteString.hasPrefix(API.BASE_URL) == true, let accessToken = keychain.get("AccessToken") else {
            completion(.success(urlRequest))
            return
        }
        
        var request = urlRequest
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        completion(.success(urlRequest))
        
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("BaseInterceptor - retry() called")
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 400 else {
            print(".doNotRetry")
            completion(.doNotRetryWithError(error))
            return
        }
        
        print(".retry")
        
        let url = API.BASE_URL + "/token"
        let headers: HTTPHeaders = [
            "Authorization" : keychain.get("RefreshToken") ?? ""
        ]
        
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                
                // Token - Dictionary to String
                let tokens = String((response.response?.headers.dictionary["Authorization"] ?? ""))
                let splitToken = tokens.components(separatedBy: ",")
                let refreshStartIndex = splitToken[0].index(splitToken[0].startIndex,
                                                                offsetBy: 14)
                let accessStartIndex = splitToken[1].index(splitToken[1].startIndex,
                                                               offsetBy: 13)
            
                let refreshToken = String(splitToken[0][refreshStartIndex...])
                var accessToken = String(splitToken[1].dropLast())
                accessToken = String(accessToken[accessStartIndex...])
            
                // Keychain Setting
            
                self.keychain.clear()
                self.keychain.set(accessToken, forKey: "AccessToken")
                self.keychain.set(refreshToken, forKey: "RefreshToken")
            
            case .failure(_):
                completion(.doNotRetryWithError(error))
            }
        }
    }
}

