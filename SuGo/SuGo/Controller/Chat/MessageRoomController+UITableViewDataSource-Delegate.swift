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
    let sendMessageCell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell",
                                                        for: indexPath) as! SendMessageCell
    let receiveMessageCell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell",
                                                           for: indexPath) as! ReceiveMessageCell
    guard messageRoom.count > 0 else { return UITableViewCell() }
    if messageRoom[indexPath.row].myIndex == messageRoom[indexPath.row].senderIndex { // 보낸 쪽지
      sendMessageCell.messageView.layer.cornerRadius = 12
      sendMessageCell.messageView.layer.masksToBounds = true
      sendMessageCell.messageLabel.text = messageRoom[indexPath.row].message
      sendMessageCell.messageTimeLabel.text = messageRoom[indexPath.row].messageTime
      return sendMessageCell
    } else { // 받은쪽지
      receiveMessageCell.messageView.layer.cornerRadius = 12
      receiveMessageCell.messageView.layer.masksToBounds = true
      receiveMessageCell.messageLabel.text = messageRoom[indexPath.row].message
      receiveMessageCell.messageTimeLabel.text = messageRoom[indexPath.row].messageTime
      return receiveMessageCell
    }
  }
  
}
