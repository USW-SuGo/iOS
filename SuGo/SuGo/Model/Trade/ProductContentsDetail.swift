//
//  Post.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/14.
//

import Foundation

import Alamofire
import SwiftyJSON

struct ProductContentsDetail: PostProtocol {  
  
  var productIndex: Int = 0
  var imageLink: [String] = [""]
  var contactPlace: String = ""
  var updatedAt: String = ""
  var title: String = ""
  var price: String = ""
  var nickname: String = ""
  var category: String = ""
  var content: String = ""
  var userIndex: Int = 0
  var userLikeStatus: Bool = false
  var myIndex: Int = 0
  
  mutating func jsonToProductContentsDetail(json: JSON) {
    self.productIndex = json["productPostId"].intValue
    self.contactPlace = json["contactPlace"].stringValue
    self.title = json["title"].stringValue
    self.price = decimalWon(price: json["price"].intValue)
    self.nickname = json["nickname"].stringValue
    self.category = json["category"].stringValue
    self.content = json["content"].stringValue
    self.userIndex = json["writerId"].intValue
    self.userLikeStatus = json["userLikeStatus"].boolValue
    
    let jsonImages = json["imageLink"].stringValue
    var images = jsonImages.components(separatedBy: ", ").map({String($0)})

    // JSON으로 내려받을 때 stringValue로 떨어지기에, 콤마로 스플릿 후 데이터 일부 수정
    if images.count == 1 {
        images[0] = String(images[0].dropFirst())
        images[0] = String(images[0].dropLast())
    } else {
        images[0] = String(images[0].dropFirst())
        images[images.count - 1] = String(images[images.count - 1].dropLast())
    }

    self.imageLink = images

    let postDate = json["updatedAt"].stringValue.components(separatedBy: "T")[0]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.date(from: postDate) ?? nil
    let interval = Date().timeIntervalSince(startDate ?? Date())
    let intervalDays = Int((interval) / 86400)

    self.updatedAt = dayToUpdateAt(day: intervalDays)
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
