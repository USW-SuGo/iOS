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
  
  let messageList: [MessageList] = []

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
    print(json)
    let messageRoomIMade = json["LoadNoteListCreatingByRequestUserForm"]
    let messageRoomOpponentMade = json["LoadNoteListCreatingByOpponentUserForm"]
    
    for i in 0..<messageRoomIMade.count {
      print(messageRoomIMade[i]["opponentUserNickname"])
      let date = messageRoomIMade[i]["recentChattingDate"].stringValue
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MM-dd HH:mm"
      let str = dateFormatter.date(from: date)
      print(str)
      
    }
    for i in 0..<messageRoomOpponentMade.count {
      print(messageRoomOpponentMade[i]["creatingUserNickname"])
    }
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
