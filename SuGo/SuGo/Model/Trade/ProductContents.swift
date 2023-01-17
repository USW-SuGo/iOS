//
//  Home.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/29.
//

import Foundation
import UIKit

import SwiftyJSON


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

  func jsonToCollectionViewData(i: Int, json: JSON) -> ProductContents {
      let jsonImages = json[i]["imageLink"].stringValue
      var images = jsonImages.components(separatedBy: ", ").map({String($0)})
      
      // when get data it is stringValue, so split use ','
      if images.count == 1 {
        images[0] = String(images[0].dropFirst())
        images[0] = String(images[0].dropLast())
      } else {
        images[0] = String(images[0].dropFirst())
        images[images.count - 1] = String(images[images.count - 1].dropLast())
      }
      
      // localDateTime to yyyy-mm-dd to 오늘 / 어제 / n일 전 등
      let postDate = json[i]["updatedAt"].stringValue.components(separatedBy: "T")[0]
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.date(from: postDate) ?? nil
      let interval = Date().timeIntervalSince(startDate ?? Date())
      let intervalDays = Int((interval) / 86400)
      var updatedAt = ""
      
      if intervalDays < 1 {
        updatedAt = "오늘"
      } else if intervalDays == 1 {
        updatedAt = "어제"
      } else if intervalDays < 7 {
        updatedAt = "\(intervalDays)일 전"
      } else if intervalDays < 30 {
        updatedAt = "\(intervalDays / 7)주 전"
      } else {
        updatedAt = "\(intervalDays / 30)달 전"
      }
      
      return ProductContents(productIndex: json[i]["productPostId"].intValue,
                                    imageLink: images,
                                    contactPlace: json[i]["contactPlace"].stringValue,
                                    updatedAt: updatedAt,
                                    title: json[i]["title"].stringValue,
                                    price: decimalWon(price: json[i]["price"].intValue),
                                    nickname: json[i]["nickname"].stringValue,
                                    category: json[i]["category"].stringValue,
                                    status: json[i]["status"].boolValue)
  }
    
  func decimalWon(price: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
    
    return result
  }
  
}

class CategorySelect {
    
    static let shared = CategorySelect()
    
    var homeCategory: String = ""
    var postCategory: String = "기타"
    
    private init() {}
    
}
