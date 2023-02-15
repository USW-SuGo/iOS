//
//  Home.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/29.
//

import Foundation
import UIKit

import SwiftyJSON


struct ProductContents: PostProtocol {
    
  var productIndex: Int = 0
  var imageLink: String = ""
  var contactPlace: String = ""
  var updatedAt: String = ""
  var title: String = ""
  var price: String = ""
  var nickname: String = ""
  var category: String = ""
  var status: Bool = false

  func jsonToProductContents(json: JSON) -> ProductContents {
    let jsonImages = json["imageLink"].stringValue
    let images = jsonImages.components(separatedBy: ",").map({String($0)})
    
    // when get data it is stringValue, so split use ','
//    if images.count == 1 {
//      images[0] = String(images[0].dropFirst())
//      images[0] = String(images[0].dropLast())
//    } else {
//      images[0] = String(images[0].dropFirst())
//      images[images.count - 1] = String(images[images.count - 1].dropLast())
//    }
    
    // localDateTime to yyyy-mm-dd to 오늘 / 어제 / n일 전 등
    let postDate = json["updatedAt"].stringValue.components(separatedBy: "T")[0]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.date(from: postDate) ?? nil
    let interval = Date().timeIntervalSince(startDate ?? Date())
    let intervalDays = Int((interval) / 86400)

    return ProductContents(productIndex: json["productPostId"].intValue,
                                  imageLink: images[0],
                                  contactPlace: json["contactPlace"].stringValue,
                                  updatedAt: dayToUpdateAt(day: intervalDays),
                                  title: json["title"].stringValue,
                                  price: decimalWon(price: json["price"].intValue),
                                  nickname: json["nickname"].stringValue,
                                  category: json["category"].stringValue,
                                  status: json["status"].boolValue)
  }
    
  func decimalWon(price: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
    
    return result
  }
  
  func dayToUpdateAt(day: Int) -> String {
    switch day {
    case 0:
      return "오늘"
    case 1:
      return "어제"
    case 2..<7:
      return "\(day)일 전"
    case 7..<30:
      return "\(day / 7)주 전"
    case 30...:
      return "\(day / 30)달 전"
    default:
      print("default")
      return ""
    }
  }
  
}

class CategorySelect {
    
    static let shared = CategorySelect()
    
    var homeCategory: String = ""
    var postCategory: String = "기타"
    
    private init() {}
    
}
