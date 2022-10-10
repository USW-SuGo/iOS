//
//  AlamofireManager.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/03.
//

import Foundation
import Alamofire

final class AlamofireManager {
    
    static let shared = AlamofireManager()
    
    let interceptors = Interceptor(interceptors:
                        [
                            BaseInterceptor()
                        ])
    
    let monitors = [MyLogger(), ApiStatusLogger()] as [EventMonitor]
    
    var session: Session
    
    private init() {
        session = Session(
            interceptor: interceptors,
            eventMonitors: monitors
        )
    }
    
}
