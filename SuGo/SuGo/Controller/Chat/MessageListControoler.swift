//
//  ChatingListController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/21.
//

import UIKit

import Alamofire
import SwiftyJSON

class MessageListControoler: UIViewController {

  //MARK: IBOutlets
    
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  
  var messageList: [MessageList] = []
  var page = 0
  private lazy var refresh: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(callRefresh), for: .valueChanged)
    return refreshControl
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    customBackButton()
    customRightBarButton()
    tableView.refreshControl = refresh
    getMessageList(page: page, size: 10)
  }

  //MARK: Functions
  
  // refreshControl 추가 필요
  
  @objc
  private func callRefresh() {
    tableView.refreshControl?.beginRefreshing()
    page = 0
    messageList.removeAll()
    getMessageList(page: page, size: 10)
    tableView.refreshControl?.endRefreshing()
  }
  
  private func getMessageList(page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(MessageRouter.messageList(page: page, size: size))
      .validate()
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        self.jsonToTableViewData(json: JSON(response.data ?? ""))
        print(JSON(response.data ?? ""))
      }
  }
  
  private func jsonToTableViewData(json: JSON) {
    for i in 0..<json.count {
      let message = MessageList(roomIndex: json[i]["noteId"].intValue,
                                myIndex: json[i]["requestUserId"].intValue,
                                oppositeIndex: json[i]["opponentUserId"].intValue,
                                oppositeNickname: json[i]["opponentUserNickname"].stringValue,
                                recentMessage: json[i]["recentContent"].stringValue,
                                recentMessageTime: dateToString(localDateTime: json, index: i),
                                newMessageCount: json[i]["requestUserUnreadCount"].intValue)
      messageList.append(message)
    }
    print(messageList)
    tableView.reloadData()
  }
  
  private func dateToString(localDateTime: JSON, index: Int) -> String {
    let localDateTime = localDateTime[index]["recentChattingDate"].stringValue
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let convertLocalToDate = dateFormatter.date(from: localDateTime) ?? Date()
    dateFormatter.dateFormat = "MM-dd HH:mm"
    let recentMessageTime = dateFormatter.string(from: convertLocalToDate)
    print(recentMessageTime)
    
    return recentMessageTime
  }
  
  @objc
  private func closeButtonClicked() {
    dismiss(animated: true)
  }
    
  //MARK: Button Actions
  
  //MARK: Design Functions
  
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }

  private func customRightBarButton() {
    let closeButton = self.navigationItem.makeSFSymbolButton(self,
                                                             action: #selector(closeButtonClicked),
                                                             symbolName: "xmark")
    self.navigationItem.rightBarButtonItem = closeButton
  }
   
}

extension MessageListControoler: UITableViewDelegate, UITableViewDataSource {
  
  // 무한 스크롤 추가 필요
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "messageListCell", for: indexPath) as! MessageListCell
    cell.userNicknameLabel.text = messageList[indexPath.row].oppositeNickname
    cell.recentMessageLabel.text = messageList[indexPath.row].recentMessage
    cell.recentMessageTimeLabel.text = messageList[indexPath.row].recentMessageTime
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let messageRoomView = UIStoryboard(name: "MessageRoomView", bundle: nil)
    let messageRoomController = messageRoomView.instantiateViewController(withIdentifier: "messageRoomVC")
    as! MessageRoomController
    messageRoomController.sendMessage.roomIndex = messageList[indexPath.row].roomIndex
    messageRoomController.sendMessage.myIndex = messageList[indexPath.row].myIndex
    messageRoomController.sendMessage.oppositeIndex = messageList[indexPath.row].oppositeIndex
    navigationController?.pushViewController(messageRoomController, animated: true)
  }
  
}

class MessageListCell: UITableViewCell {
  
  @IBOutlet weak var userNicknameLabel: UILabel!
  @IBOutlet weak var recentMessageLabel: UILabel!
  @IBOutlet weak var recentMessageTimeLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func layoutSubviews() {
  }
  
}
