//
//  UserPage.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/04.
//

import Foundation

import SwiftyJSON

struct UserPage {
  var userIndex: Int = 0
  var userEmail: String = ""
  var userNickname: String = ""
  var userMannerGrade: String = ""
  var userEvaluationCount: String = ""
  var userTradeCount: String = ""
  
  init() {}
  
  init(json: JSON) {
    self.userIndex = json["userId"].intValue
    self.userEmail = json["email"].stringValue
    self.userNickname = json["nickname"].stringValue
    self.userMannerGrade = String(json["mannerGrade"].doubleValue)
    self.userEvaluationCount = json["countMannerEvaluation"].stringValue
    self.userTradeCount = json["countTradeAttempt"].stringValue
  }
}

struct UserPagePost {
  var productIndex: Int = 0
  var title: String = ""
  var price: String = ""
  var category: String = ""
  var status: Bool = false
  var imageLink: String = ""
  var contactPlace: String = ""
  var updatedAt: String = ""
  
  init() {}
  
  init(json: JSON) {
    self.productIndex = json["productPostId"].intValue
    self.title = json["title"].stringValue
    self.price = decimalWon(price: json["price"].intValue)
    self.category = json["category"].stringValue
    self.status = json["status"].boolValue
    self.imageLink = json["imageLink"].stringValue
    self.contactPlace = json["contactPlace"].stringValue
    self.updatedAt = dayToUpdateAt(dateString: json["updateAt"].stringValue)
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
