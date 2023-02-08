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
  
  init() {
  }
  
  init(json: JSON) {
    self.productIndex = json["productPostId"].intValue
    self.contactPlace = json["contactPlace"].stringValue
    self.title = json["title"].stringValue
    self.price = decimalWon(price: json["price"].intValue)
    self.nickname = json["nickname"].stringValue
    self.category = json["category"].stringValue
    self.content = json["content"].stringValue
    self.userIndex = json["writerId"].intValue
    self.userLikeStatus = json["userLikeStatus"].boolValue
    self.imageLink = imagesFromJsonString(json["imageLink"].stringValue)
    self.updatedAt = dayToUpdateAt(dateString: json["updateAt"].stringValue)
    self.myIndex = 1
  }

  func imagesFromJsonString(_ jsonImageString: String) -> [String] {
    let images = jsonImageString.components(separatedBy: ", ").map { String($0) }
    return images
  }
  
  func decimalWon(price: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
    
    return result
  }
  
  func dayToUpdateAt(dateString: String) -> String {
    let postDate = dateString.components(separatedBy: "T")[0]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.date(from: postDate)
    let date = Int((Date().timeIntervalSince(startDate ?? Date())) / 86400)
    
    switch date {
    case 0:
      return "오늘"
    case 1:
      return "어제"
    case 2..<7:
      return "\(date)일 전"
    case 7..<30:
      return "\(date / 7)주 전"
    case 30...:
      return "\(date / 30)달 전"
    default:
      print("default")
      return ""
    }
  }
  
}
