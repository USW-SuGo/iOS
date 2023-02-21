//
//  MessageRoomController+UITableViewDataSource-Delegate.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/21.
//

import UIKit



extension MessageRoomController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    print(indexPath)
    if indexPath.row == 5 {
      page += 1
      if !lastPage {
        indexPathRow = indexPath.row
        getMessageRoom(roomIndex: sendMessage.roomIndex, page: page, size: 20)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageRoom.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "messageRoomCell", for: indexPath) as! MessageRoomCell
    guard messageRoom.count > 0 else { return }
    if messageRoom[indexPath.row].myIndex == messageRoom[indexPath.row].senderIndex { // 보낸 쪽지
        cell.messageView.layer.cornerRadius = 12
        cell.messageView.layer.masksToBounds = true
        cell.messageLabel.text = messageRoom[indexPath.row].message
        cell.messageTimeLabel.text = messageRoom[indexPath.row].messageTime
      return cell
    } else { // 받은쪽지
      
      return cell
    }

  }
  
}
