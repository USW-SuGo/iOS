//
//  File.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/07.
//

import Foundation
import SwiftyJSON

struct MyPage {
    
  var userIndex: String = ""
  var userEmail: String = ""
  var userNickname: String = ""
  var userMannerGrade: String = ""
  var userEvaluationCount: Int = 0
  var userTradeCount: Int = 0
  
  mutating func updateMyPage(json: JSON) {
    self.userIndex = json["id"].stringValue
    self.userEmail = json["email"].stringValue
    self.userNickname = json["nickname"].stringValue
    self.userMannerGrade = json["mannerGrade"].stringValue
    self.userEvaluationCount = json["countMannerEvaluation"].intValue
    self.userTradeCount = json["countTradeAttempt"].intValue
  }
}

struct MyPagePosting: PostProtocol {
    
  var productIndex: Int = 0
  var title: String = ""
  var price: String = ""
  var decimalWon: String = ""
  var category: String = ""
  var status: Bool = false
  var imageLink: String = ""
  var contactPlace: String = ""
  var updatedAt: String = ""
  
  mutating func jsonToMyPagePosting(json: JSON) -> MyPagePosting {
    let postDate = json["updatedAt"].stringValue.components(separatedBy: "T")[0]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let startDate = dateFormatter.date(from: postDate) ?? nil
    let interval = Date().timeIntervalSince(startDate ?? Date())
    let intervalDays = Int((interval) / 86400)
    print("productPostId : \(json["productPostId"].intValue)")
    return MyPagePosting(productIndex: json["productPostId"].intValue,
                        title: json["title"].stringValue,
                        price: json["price"].stringValue,
                        decimalWon: decimalWon(price: json["price"].intValue),
                        category: json["category"].stringValue,
                        status: json["status"].boolValue,
                        imageLink: json["imageLink"].stringValue,
                        contactPlace: json["contactPlace"].stringValue,
                        updatedAt: dayToUpdateAt(day: intervalDays))
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
      return ""
    }
  }
  
}
