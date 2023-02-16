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
// 유저 정보에서는 새로고침을 구현하지 않음.
class UserInfoController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userNicknameLabel: UILabel!
  @IBOutlet weak var userMannerGradeLabel: UILabel!
  @IBOutlet weak var userTradeCountLabel: UILabel!
  @IBOutlet weak var salePostButton: UIButton!
  @IBOutlet weak var soldOutButtonClicked: UIButton!
  @IBOutlet weak var seperateLine: UIView!
  
  //MARK: Properties
  
  let noPostLabel: UILabel = {
    let noPostLabel = UILabel()
    noPostLabel.numberOfLines = 0
    noPostLabel.text =
    """
                아직 판매 중인 상품이 없어요!
    해당 유저가 아직 상품을 판매 중이지 않습니다.
    """
    noPostLabel.font = UIFont(name: "Pretendard-regular", size: 17)
    noPostLabel.textColor = UIColor.darkGray
    return noPostLabel
  }()
  
  var userId: Int?
  var userPage = UserPage()
  var userPagePost = UserPagePost()
  var userPost: [UserPagePost] = []
  var postPage = 0
  var postLastPage = false
  var userSoldOutPost: [UserPagePost] = []
  var soldOutPostPage = 0
  var soldOutPostLastPage = false
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeUserInfo()
  }
  
  //MARK: Functions
  
  private func initializeUserInfo() {
    setUpNavigationTitle()
    setUpSubViews()
    setUpConstraints()
    customBackButton()
    registerXib()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    if let userId = userId {
      getUserPage(userId: userId)
      getUserPost(userId: userId, page: postPage, size: 10)
      getUserSoldOutPost(userId: userId, page: postPage, size: 10)
    }
    tableView.tag = 1
  }
  
  // A - B
  // A가 쪽지를 삭제
  // B는 쪽지 그대로 있어야 함.

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
  
  func getUserPost(userId: Int, page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.getUserPost(userId: userId, page: page, size: size))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data else { return }
        self.updateUserSalePosting(json: JSON(responseData))
      }
  }
  
  // 새로고침 없음.
  private func updateUserSalePosting(json: JSON) {
    guard json.count > 0// 만약 게시글이 30개라면?
    else {
      if tableView.tag == 1 && userPost.count == 0 {
        noPostLabel.text =
        """
                    아직 판매 중인 상품이 없어요!
        해당 유저가 아직 상품을 판매 중이지 않습니다.
        """
        noPostLabel.isHidden = false
        tableView.isHidden = true
        tableView.reloadData()
      }
      return
    }
    if json.count < 10 { postLastPage = true }
    for i in 0..<json.count {
      userPagePost = UserPagePost(json: json[i])
      userPost.append(userPagePost)
    }
    tableView.reloadData()
  }
  
  func getUserSoldOutPost(userId: Int, page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.getUserSoldOutPost(userId: userId, page: page, size: size))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data else { return }
        self.updateUserSoldOutPosting(json: JSON(responseData))
      }
  }
  
  private func updateUserSoldOutPosting(json: JSON) {
    guard json.count > 0 else{
      return
    }
    if json.count < 10 { soldOutPostLastPage = true }
    for i in 0..<json.count {
      userPagePost = UserPagePost(json: json[i])
      userSoldOutPost.append(userPagePost)
    }
  }
  
  //MARK: Button Actions
  
  @IBAction func salePostButtonClicked(_ sender: Any) {
    salePostButton.setTitleColor(.black, for: .normal)
    soldOutButtonClicked.setTitleColor(.lightGray, for: .normal)
    
    guard userPost.count > 0 else {
      tableView.isHidden = true
      noPostLabel.text =
      """
                  아직 판매 중인 상품이 없어요!
      해당 유저가 아직 상품을 판매 중이지 않습니다.
      """
      noPostLabel.isHidden = false
      return
    }
    noPostLabel.isHidden = true
    tableView.tag = 1
    tableView.isHidden = false
    tableView.reloadData()

  }
  
  @IBAction func soldOutButtonClicked(_ sender: Any) {
    salePostButton.setTitleColor(.lightGray, for: .normal)
    soldOutButtonClicked.setTitleColor(.black, for: .normal)

    guard userSoldOutPost.count > 0 else {
      tableView.isHidden = true
      noPostLabel.isHidden = false
      noPostLabel.text =
      """
                   아직 판매완료된 상품이 없어요!
      해당 유저의 상품 중 판매완료된 상품이 없습니다.
      """
      return
    }
    noPostLabel.isHidden = true
    tableView.tag = 2
    tableView.isHidden = false
    tableView.reloadData()
  }
  
  //MARK: Design Functions
  
  private func setUpNavigationTitle() {
    let font = UIFont(name: "Pretendard-medium", size: 17) ?? UIFont.systemFont(ofSize: 17)
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : font]
  }
  
  private func setUpSubViews() {
    self.view.addSubview(noPostLabel)
    noPostLabel.isHidden = true
  }
  
  private func setUpConstraints() {
    let topConstant = (seperateLine.frame.minY + view.frame.minY) / 2
    noPostLabel.translatesAutoresizingMaskIntoConstraints = false
    noPostLabel.topAnchor.constraint(equalTo: seperateLine.topAnchor, constant: topConstant).isActive = true
    noPostLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    noPostLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
  
  
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
