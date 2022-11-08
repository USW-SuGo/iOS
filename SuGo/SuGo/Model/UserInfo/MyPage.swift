//
//  File.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/07.
//

import Foundation

struct MyPage {
    
    var userIndex: String = ""
    var userEmail: String = ""
    var userNickname: String = ""
    var userMannerGrade: String = ""
    var userEvaluationCount: Int = 0
    var userTradeCount: Int = 0
    
}

struct MyPagePosting {
    
    var userIndex: String = ""
    var title: String = ""
    var price: String = ""
    var status: Bool = false
    var imageLink: String = ""
    var contactPlace: String = ""
    var updatedAt: String = ""
    
}
