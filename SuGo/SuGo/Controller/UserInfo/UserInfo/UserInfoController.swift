//
//  UserInfoController.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/27.
//

import UIKit

import Alamofire
import SwiftyJSON

// push vc로 화면 띄워줘야 함.
class UserInfoController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userNicknameLabel: UILabel!
  @IBOutlet weak var userMannerGradeLabel: UILabel!
  @IBOutlet weak var userTradeCountLabel: UILabel!
  @IBOutlet weak var salePostButton: UIButton!
  @IBOutlet weak var soldOutButtonClicked: UIButton!
  
  //MARK: Properties
  
  var userId: Int?
  var userPage = UserPage()
  var userPagePosting = UserPagePosting()
  var userSalePosting: [UserPagePosting] = []
  var salePostingPage = 0
  var salePostingLastPage = false
  var userSoldOutPosting: [UserPagePosting] = []
  var soldOutPostingPage = 0
  var soldOutPostingLastPage = false
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    customBackButton()
    registerXib()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    if let userId = userId {
      getUserPage(userId: userId, page: 0, size: 10)
    }
    tableView.tag = 1
    print("userId: \(userId ?? 1123131313)")
  }
  
  //MARK: Functions
  
  private func registerXib() {
    let userPostingXib = UINib(nibName: "MyPostingCell", bundle: nil)
    tableView.register(userPostingXib, forCellReuseIdentifier: "myPostingCell")
    let likePostingXib = UINib(nibName: "UserPostingCell", bundle: nil)
    tableView.register(likePostingXib, forCellReuseIdentifier: "userPostingCell")
    let emptyPostingXib = UINib(nibName: "EmptyPostingCell", bundle: nil)
    tableView.register(emptyPostingXib, forCellReuseIdentifier: "emptyPostingCell")
  }
 
  //MARK: API Functions
  // 데이터 받아온 후에 Model에서 Initialize -> return instance()
  func getUserPage(userId: Int, page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.userPage(userId: userId, page: page, size: size))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data else { return }
        self.userPage = UserPage(json: JSON(responseData))
        self.updateUserPage()
        self.updateUserSalePosting(json: JSON(responseData)["myPostings"])
        self.updateUserSoldOutPosting(json: JSON(responseData)["closePostings"])
        print(self.userPage)
      }
  }
  
  private func updateUserSalePosting(json: JSON) {
    if json.count < 10 { salePostingLastPage = true }
    for i in 0..<json.count {
      userPagePosting = UserPagePosting(json: json[i])
      userSalePosting.append(userPagePosting)
    }
    tableView.reloadData()
  }
  
  private func updateUserSoldOutPosting(json: JSON) {
    if json.count < 10 { soldOutPostingLastPage = true }
    for i in 0..<json.count {
      userPagePosting = UserPagePosting(json: json[i])
      userSoldOutPosting.append(userPagePosting)
    }
    print(userSoldOutPosting)
  }
  
  //MARK: Button Actions
  
  @IBAction func salePostButtonClicked(_ sender: Any) {
    tableView.tag = 1
    tableView.reloadData()
    salePostButton.setTitleColor(.black, for: .normal)
    soldOutButtonClicked.setTitleColor(.lightGray, for: .normal)
    print(userSalePosting)
  }
  
  @IBAction func soldOutButtonClicked(_ sender: Any) {
    tableView.tag = 2
    tableView.reloadData()
    salePostButton.setTitleColor(.lightGray, for: .normal)
    soldOutButtonClicked.setTitleColor(.black, for: .normal)
    print(userSoldOutPosting)
  }
  
  //MARK: Design Functions
  
  private func updateUserPage() {
    userNicknameLabel.text = userPage.userNickname
    userMannerGradeLabel.text = userPage.userMannerGrade
    userTradeCountLabel.text = userPage.userTradeCount
  }
  
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
}
