//
//  ChatList.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/15.
//

import Foundation

struct ChatList {
  // 채팅방 만든사람 id - 구매자
  // 채팅방 만든사람 닉네임 - ?
  //
  var roomIndex: Int?
  var oppositeIndex: Int?
  var oppositeNickname: String?
  var recentChat: String?
  var recentChatTime: String?
}
