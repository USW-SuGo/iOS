//
//  Home.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/29.
//

import Foundation
import UIKit


struct ProductContents {
    
  var productIndex: Int = 0
  var imageLink: [String] = [""]
  var contactPlace: String = ""
  var updatedAt: String = ""
  var title: String = ""
  var price: String = ""
  var nickname: String = ""
  var category: String = ""
  var status: Bool = false

}

class CategorySelect {
    
    static let shared = CategorySelect()
    
    var homeCategory: String = ""
    var postCategory: String = "기타"
    
    private init() {}
    
}
