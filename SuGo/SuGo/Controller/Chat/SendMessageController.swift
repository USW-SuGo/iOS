//
//  SendMessageController.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/21.
//

import UIKit

import Alamofire
import SwiftyJSON

class SendMessageController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var messageTextView: UITextView!
  
  //MARK: Properties
  
  let textViewPlaceHolder = "메세지를 입력하세요."
  var sendMessage = SendMessage()
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    designButton()
    messageTextView.text = textViewPlaceHolder
    messageTextView.textColor = .lightGray
    messageTextView.delegate = self
    super.viewDidLoad()
  }
  
  //MARK: Functions
  
  //MARK: Button Actions
  
  @IBAction func sendMessageButtonClicked(_ sender: Any) {
    
    guard let message = messageTextView.text else { return }
    
    AlamofireManager
      .shared
      .session
      .request(MessageRouter.sendMessage(roomIndex: sendMessage.roomIndex,
                                         message: message,
                                         senderId: sendMessage.myIndex,
                                         receiverId: sendMessage.oppositeIndex))
      .validate()
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        print("dismiss")
        self.dismiss(animated: true)
      }
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    dismiss(animated: true)
  }
  
  //MARK: Design Functions
  
  private func designButton() {
    sendButton.layer.cornerRadius = 6.0
    sendButton.layer.borderColor = UIColor.white.cgColor
    sendButton.layer.borderWidth = 0.7
  }
  
}

extension SendMessageController: UITextViewDelegate {
  

  func textViewDidBeginEditing(_ textView: UITextView) {
    if messageTextView.text == textViewPlaceHolder {
        messageTextView.text = nil
        messageTextView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      messageTextView.text = textViewPlaceHolder
      messageTextView.textColor = .lightGray
    }
  }
  
}
