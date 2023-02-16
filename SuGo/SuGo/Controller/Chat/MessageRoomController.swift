//
//  ChatingRoomController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/27.
//

import UIKit

import Alamofire
import IQKeyboardManagerSwift
import SwiftyJSON

protocol MessageRoomIndex {
  func getIndex(roomIndex: Int, myIndex: Int, oppositeIndex: Int)
}

// 게시물 정보, 채팅방 형태
class MessageRoomController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var messageView: UIView!
  @IBOutlet weak var messageTextView: UITextView!
  @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
  @IBOutlet weak var messageViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var sendButton: UIButton!
  
//  @IBOutlet weak var messageTextViewHeight: NSLayoutConstraint!
  //MARK: Properties
  
  var sendMessage = SendMessage()
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  var messageRoom: [MessageRoom] = []
  var page = 0
  var lastPage = false
  var messageHeight: CGFloat = 35
  private lazy var refresh: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(callRefresh), for: .valueChanged)
    return refreshControl
  }()
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    IQKeyboardManager.shared.enable = false
    IQKeyboardManager.shared.enableAutoToolbar = false
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    customMessageTextView()
    messageTextView.delegate = self
    // 채팅 스크롤 안보이도록 설정
    messageTextView.showsVerticalScrollIndicator = false
    // 채팅 길게 작성 시 문장 단위로 넘어가지 않도록, 글자 단위로 넘어가도록 설정
    messageTextView.textContainer.lineBreakMode = .byCharWrapping
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 80
    tableView.refreshControl = refresh
    customRightBarButton()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("view will appear")
    initializeMessageRoom()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.enableAutoToolbar = true
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
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
      .response { response in
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
  
  private func customMessageTextView() {
    messageView.layer.cornerRadius = 6.0
    sendButton.layer.cornerRadius = 15.0
    
  }
  
  @objc func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    else { return }

    let keyboardHeight = keyboardFrame.height
    UIView.animate(withDuration: 0.25) {
      self.view.frame.origin.y = -keyboardHeight
    }
}

  @objc func keyboardWillHide(_ notification: Notification) {
    UIView.animate(withDuration: 0.25) {
        self.view.frame.origin.y = 0
    }
  }
  
  private func customRightBarButton() {
    let sendButton = self.navigationItem.makeSFSymbolButton(self,
                                                            action: #selector(sendButtonClicked),
                                                            symbolName: "paperplane")
    self.navigationItem.rightBarButtonItem = sendButton
  }

}

extension MessageRoomController: UITextViewDelegate {
  
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    messageTextViewHeight.constant = messageHeight
    return true
  }
  
  // 채팅창 max height == 100, 채팅 중에는 100까지 height 증가
  func textViewDidChange(_ textView: UITextView) {
    guard messageTextViewHeight.constant != 100 else {
      return
    }
    messageTextView.sizeToFit()
    let maxHeight: CGFloat = 100
    let minHeight: CGFloat = 35
    messageHeight = max(min(textView.contentSize.height, maxHeight), minHeight)
    messageViewHeight.constant = messageHeight
    messageTextViewHeight.constant = messageHeight
    
  }
  
  // 채팅 입력 완료 시 height 35
  func textViewDidEndEditing(_ textView: UITextView) {
    print(#function)
    messageTextViewHeight.constant = 35
    messageViewHeight.constant = 35
    messageTextView.contentOffset = .zero
  }
  
}

extension MessageRoomController: MessageRoomIndex {
  func getIndex(roomIndex: Int, myIndex: Int, oppositeIndex: Int) {
    self.sendMessage.roomIndex = roomIndex
    self.sendMessage.myIndex = myIndex
    self.sendMessage.oppositeIndex = oppositeIndex
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
