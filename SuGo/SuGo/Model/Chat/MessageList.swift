//
//  ChatList.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/15.
//

import Foundation

import SwiftyJSON

struct MessageList {
  var roomIndex: Int = 0
  var myIndex: Int = 0
  var oppositeIndex: Int = 0
  var oppositeNickname: String = ""
  var productIndex: Int = 0
  var recentMessage: String = ""
  var recentMessageTime: String = ""
  var newMessageCount: Int = 0
  
  init() { }
  
  init(json: JSON, requestUserId: Int) {
    self.roomIndex = json["noteId"].intValue
    let (myIndex, oppositeIndex) = checkIndex(requestUserId: requestUserId,
                                              creatingUserId: json["creatingUserId"].intValue,
                                              opponentUserId: json["opponentUserId"].intValue)
    self.myIndex = myIndex
    self.oppositeIndex = oppositeIndex
    self.oppositeNickname = json["opponentUserNickname"].stringValue
    self.productIndex = json["productPostId"].intValue
    self.recentMessage = json["recentContent"].stringValue
    self.recentMessageTime = dateToString(localDateTime: json)
    self.newMessageCount = json["requestUserUnreadCount"].intValue
  }
  
  private func checkIndex(requestUserId: Int,
                          creatingUserId: Int,
                          opponentUserId: Int) -> (Int, Int) {
    let (myIndex, oppositeIndex) = requestUserId == opponentUserId
    ? (opponentUserId, creatingUserId) : (creatingUserId, opponentUserId)
    return (myIndex, oppositeIndex)
  }
  
  private func dateToString(localDateTime: JSON) -> String {
    let localDateTime = localDateTime["recentChattingDate"].stringValue
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let convertLocalToDate = dateFormatter.date(from: localDateTime) ?? Date()
    dateFormatter.dateFormat = "MM-dd HH:mm"
    let recentMessageTime = dateFormatter.string(from: convertLocalToDate)
    print(recentMessageTime)
    
    return recentMessageTime
  }
  
}
