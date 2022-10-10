//
//  ApiStatusLogger.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation

import Alamofire

final class ApiStatusLogger: EventMonitor {
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        
        guard let statusCode = request.response?.statusCode else { return }
        
        print("ApiStatusLogger - statusCode : \(statusCode)")
        
    }
    
}
