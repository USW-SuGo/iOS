//
//  EvaluateController.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/24.
//

import UIKit

import Alamofire
import SwiftyJSON

class EvaluateController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var userNicknameLabel: UILabel!
  @IBOutlet weak var userMannerGradeLabel: UILabel!
  @IBOutlet weak var userTradeCountLabel: UILabel!
  
  @IBOutlet weak var aPlusLabel: UILabel!
  @IBOutlet weak var bPlusLabel: UILabel!
  @IBOutlet weak var cPlusLabel: UILabel!
  @IBOutlet weak var dZeroLabel: UILabel!
  
  @IBOutlet weak var aPlusButton: UIButton!
  @IBOutlet weak var bPlusButton: UIButton!
  @IBOutlet weak var cPlusButton: UIButton!
  @IBOutlet weak var dZeroButton: UIButton!
  
  @IBOutlet weak var evaluateButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  
  //MARK: Properties
  
  var userId = 0
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  var userPage = UserPage()
  var senderTag = 0
  var grade: Double = 0
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    customButtons()
    customLabels()
    getUserPage(userId: userId)
    self.navigationItem.title = "유저 평가"
  }
  
  //MARK: Functions
  
  func getUserPage(userId: Int) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.userPage(userId: userId))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data else { return }
        self.userPage = UserPage(json: JSON(responseData))
        self.updateUserPage()
      }
  }
  
  func evaluateUser(userId: Int, grade: Double) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.userMannerEvaluate(userId: userId, grade: grade))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200
        else {
          self.customAlert(title: "이미 유저 평가를 하셨어요!", message: "유저 평가는 하루에 한번만 가능합니다.")
          return }
        self.customAlert(title: "유저 평가가 완료되었어요!", message: "SUGO 거래 문화에 도움을 주셔서 감사합니다!")
      }
  }
  
  func checkGrade(mainButton: UIButton, tag: Int, grade: Double, anyButtons: [UIButton]) {
    if senderTag == tag {
      mainButton.setImage(UIImage(systemName: "square"), for: .normal)
      self.grade = 0
    } else {
      mainButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
      self.grade = grade
    }
    for i in 0..<anyButtons.count {
      anyButtons[i].setImage(UIImage(systemName: "square"), for: .normal)
    }
    print(self.grade)
  }
  
  //MARK: Button Actions
  
  //  checkmark.square.fill - 체크모양
  //  square - 사각형
  
  @IBAction func checkButtonClicked(_ sender: UIButton) {
    switch sender{
    case aPlusButton:
      checkGrade(mainButton: aPlusButton,
                 tag: sender.tag,
                 grade: 4.5,
                 anyButtons: [bPlusButton, cPlusButton, dZeroButton])
    case bPlusButton:
      checkGrade(mainButton: bPlusButton,
                 tag: sender.tag,
                 grade: 3.5,
                 anyButtons: [aPlusButton, cPlusButton, dZeroButton])
    case cPlusButton:
      checkGrade(mainButton: cPlusButton,
                 tag: sender.tag,
                 grade: 2.5,
                 anyButtons: [aPlusButton, bPlusButton, dZeroButton])
    case dZeroButton:
      checkGrade(mainButton: dZeroButton,
                 tag: sender.tag,
                 grade: 1.0,
                 anyButtons: [aPlusButton, bPlusButton, cPlusButton])
    default: return
    }
    senderTag = sender.tag
  }

  @IBAction func evaluateButtonClicked(_ sender: Any) {
    guard grade > 0 else { return }
    evaluateUser(userId: userId, grade: grade)
  }
  
  @IBAction func backButtonClicked(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  //MARK: Design Functions
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
      self.dismiss(animated: true)
      self.navigationController?.popViewController(animated: true)
    }
    alert.addAction(confirmAction)
    self.present(alert, animated: true)
  }
  
  private func updateUserPage() {
    self.userNicknameLabel.text = userPage.userNickname
    self.userMannerGradeLabel.text = userPage.userMannerGrade
    self.userTradeCountLabel.text = userPage.userTradeCount
  }
  
  private func customButtons() {
    evaluateButton.layer.cornerRadius = 6.0
    backButton.layer.cornerRadius = 6.0
    backButton.layer.borderWidth = 1.0
    backButton.layer.borderColor = colorLiteralGreen.cgColor
  }
  
  private func customLabels() {
    aPlusLabel.layer.cornerRadius = 12
    aPlusLabel.layer.masksToBounds = true
    
    bPlusLabel.layer.cornerRadius = 12
    bPlusLabel.layer.masksToBounds = true
    
    cPlusLabel.layer.cornerRadius = 12
    cPlusLabel.layer.masksToBounds = true
    
    dZeroLabel.layer.cornerRadius = 12
    dZeroLabel.layer.masksToBounds = true
  }
  
}
