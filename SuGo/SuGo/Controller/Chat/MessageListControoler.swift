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

  override func viewDidLoad() {
    super.viewDidLoad()
    customRightBarButton()
    getMessageList()
  }

  //MARK: Functions
  
  private func getMessageList() {
    AlamofireManager
      .shared
      .session
      .request(MessageRouter.messageList(page: 0, size: 10))
      .validate()
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        self.jsonToCollectionViewData(json: JSON(response.data ?? ""))
      }
  }

  private func jsonToCollectionViewData(json: JSON) {
    let messageRoomIMade = json["LoadNoteListCreatingByRequestUserForm"]
    let messageRoomOpponentMade = json["LoadNoteListCreatingByOpponentUserForm"]
    print(json)
    for i in 0..<messageRoomIMade.count {
      let message = MessageList(roomIndex: messageRoomIMade[i]["roomId"].intValue,
                                oppositeIndex: messageRoomIMade[i]["opponentUserId"].intValue,
                                oppositeNickname: messageRoomIMade[i]["opponentUserNickname"].stringValue,
                                recentMessage: messageRoomIMade[i]["recentContent"].stringValue,
                                recentMessageTime: dateToString(localDateTime: messageRoomIMade, index: i),
                                newMessageCount: messageRoomIMade[i]["creatingUserUnreadCount"].intValue)
      messageList.append(message)
    }
    
    for i in 0..<messageRoomOpponentMade.count {
      let message = MessageList(roomIndex: messageRoomOpponentMade[i]["roomId"].intValue,
                                oppositeIndex: messageRoomOpponentMade[i]["creatingUserId"].intValue,
                                oppositeNickname: messageRoomOpponentMade[i]["creatingUserNickname"].stringValue,
                                recentMessage: messageRoomOpponentMade[i]["recentContent"].stringValue,
                                recentMessageTime: dateToString(localDateTime: messageRoomOpponentMade, index: i),
                                newMessageCount: messageRoomOpponentMade[i]["opponentUserUnreadCount"].intValue)
      messageList.append(message)
    }
    print(messageList)
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
  
  private func customRightBarButton() {
    let closeButton = self.navigationItem.makeSFSymbolButton(self,
                                                             action: #selector(closeButtonClicked),
                                                             symbolName: "xmark")
    self.navigationItem.rightBarButtonItem = closeButton
  }
   
}

extension MessageListControoler: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "chatingListCell", for: indexPath) as! ChatingListCell
    
    return cell
  }
}

class ChatingListCell: UITableViewCell {
  
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
