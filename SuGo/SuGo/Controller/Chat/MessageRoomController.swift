//
//  ChatingRoomController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/27.
//

import UIKit

import Alamofire
import SwiftyJSON

class MessageRoomController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  
  var sendMessage = SendMessage()
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  var messageRoom: [MessageRoom] = []
  var page = 0
  var lastPage = false
  private lazy var refresh: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(callRefresh), for: .valueChanged)
    return refreshControl
  }()
  
  // roomIndex: 6, oppositeIndex: 1, oppositeNickname: "정보보호학과-1", recentMessage: "ios\n", recentMessageTime: "11-20 19:49", newMessageCount: 0
  
//  "requestUserId": 2,
//  "productPostId": 25,
//  "noteContentId": 20,
//  "message": "ios\n",
//  "messageSenderId": 1,
//  "messageReceiverId": 2,
//  "messageCreatedAt": "2022-11-20T19:49:46",
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 80
    tableView.refreshControl = refresh
    customRightBarButton()
    initializeMessageRoom()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("view will appear")
    initializeMessageRoom()
  }
  
  //MARK: Functions
  
  private func initializeMessageRoom() {
    page = 0
    lastPage = false
    messageRoom.removeAll()
    getMessageRoom(roomIndex: sendMessage.roomIndex,
                   page: page,
                   size: 10)
  }
  
  @objc
  private func callRefresh() {
    tableView.refreshControl?.beginRefreshing()
    page = 0
    lastPage = false
    messageRoom.removeAll()
    getMessageRoom(roomIndex: sendMessage.roomIndex,
                   page: page,
                   size: 10)
    tableView.refreshControl?.endRefreshing()
  }
  
  private func getMessageRoom(roomIndex: Int, page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(MessageRouter.messageRoom(roomIndex: roomIndex, page: page, size: size))
      .validate()
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        self.jsonToTableViewData(json: JSON(response.data ?? ""))
      }
  }
  
  private func jsonToTableViewData(json: JSON) {
    if json.count < 10 {
      lastPage = true
    }
    for i in 0..<json.count {
      let message = MessageRoom(myIndex: json[i]["requestUserId"].intValue,
                                    senderIndex: json[i]["messageSenderId"].intValue,
                                    receiverIndex: json[i]["messageReceiverId"].intValue,
                                    message: json[i]["message"].stringValue,
                                    messageTime: dateToString(localDateTime: json, index: i))
      messageRoom.append(message)
    }
    tableView.reloadData()
  }
  
  private func dateToString(localDateTime: JSON, index: Int) -> String {
    let localDateTime = localDateTime[index]["messageCreatedAt"].stringValue
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let convertLocalToDate = dateFormatter.date(from: localDateTime) ?? Date()
    dateFormatter.dateFormat = "MM-dd HH:mm"
    let recentMessageTime = dateFormatter.string(from: convertLocalToDate)
    
    return recentMessageTime
  }
  
  //MARK: Button Actions
  
  @objc
  private func sendButtonClicked() {
    let sendMessageView = UIStoryboard(name: "SendMessageView", bundle: nil)
    let sendMessageController = sendMessageView.instantiateViewController(withIdentifier: "sendMessageVC")
    as! SendMessageController
    sendMessageController.sendMessage.roomIndex = sendMessage.roomIndex
    sendMessageController.sendMessage.myIndex = sendMessage.myIndex
    sendMessageController.sendMessage.oppositeIndex = sendMessage.oppositeIndex
    sendMessageController.modalPresentationStyle = .fullScreen
    present(sendMessageController, animated: true)
  }
  
  //MARK: Design Functions
  
  private func customRightBarButton() {
    let sendButton = self.navigationItem.makeSFSymbolButton(self,
                                                            action: #selector(sendButtonClicked),
                                                            symbolName: "paperplane")
    self.navigationItem.rightBarButtonItem = sendButton
  }

}

extension MessageRoomController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lastIndex = messageRoom.count - 2
    if lastIndex == indexPath.row {
      page += 1
      if !lastPage {
        getMessageRoom(roomIndex: sendMessage.roomIndex,
                       page: page,
                       size: 10)
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "messageRoomCell",
                                             for: indexPath) as! MessageRoomCell
    if messageRoom[indexPath.row].myIndex == messageRoom[indexPath.row].senderIndex {
      cell.messageTypeLabel.text = "보낸 쪽지"
      cell.messageTypeLabel.textColor = .darkGray
    } else {
      cell.messageTypeLabel.text = "받은 쪽지"
      cell.messageTypeLabel.textColor = colorLiteralGreen
    }
    
    cell.messageLabel.text = messageRoom[indexPath.row].message
    cell.messageTimeLabel.text = messageRoom[indexPath.row].messageTime
    
    return cell
  }
  
}


class MessageRoomCell: UITableViewCell {
  
  @IBOutlet weak var messageTypeLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var messageTimeLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func layoutSubviews() {
    
  }
  
}
