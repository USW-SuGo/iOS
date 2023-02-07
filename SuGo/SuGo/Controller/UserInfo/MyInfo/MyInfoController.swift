//
//  UserInfoController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/14.
//

import UIKit

import Alamofire
import KeychainSwift
import Kingfisher
import SwiftyJSON

// 1. 로그인 화면 처리
// 1-1. 게시물 수정, 삭제, 게시물 포스트업
// 1-2. 게시물 클릭 시 해당 게시물로 이동시키기 (v)
// 1-3. 로그인 화면 디자인 수정 필요 (v)

// 2. 비로그인 화면 처리 (v)
// 2-1. 상단 화면 비로그인 표시(게스트 표시)

// 3. 우측 상단 네비게이션 버튼 추가
// 3-1. 로그인
// 3-2. 비 로그인 분기처리  

class MyInfoController: UIViewController {

  //MARK: IBOutlets
    
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var userNicknameLabel: UILabel!
  @IBOutlet weak var userMannerGradeLabel: UILabel!
  @IBOutlet weak var userEvaluationCountLabel: UILabel!
  @IBOutlet weak var userTradeCountLabel: UILabel!
  @IBOutlet weak var myPostButton: UIButton!
  @IBOutlet weak var likePostButton: UIButton!
  @IBOutlet weak var guestLabel: UILabel!
  
  //MARK: Properties
  
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let keychain = KeychainSwift()
  var myPage = MyPage()
  var myPagePosting = MyPagePost()
  var myPost: [MyPagePost] = []
  var likePost: [MyPagePost] = []
  let modifyData = ModifyProduct.shared
  var myPostPage = 0
  var myPostLastPage = false
  var likePostPage = 0
  var likePostLastPage = false
  
  private lazy var refresh: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(callRefresh), for: .valueChanged)
    return refreshControl
  }()
    
  //MARK: Life Cycle
    
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.refreshControl = refresh
    tableView.separatorStyle = .none
    customRightBarButton()
    customBackButton()
    registerXib()
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("My Info View Will Appear")
    initializeMyInfo()
  }
  
  //MARK: Functions
  
  @objc
  private func callRefresh() {
    tableView.refreshControl?.beginRefreshing()
    initializeModels()
    
    switch tableView.tag{
    case 1, 3:
      getMyPost(page: myPostPage, size: 10)
    case 2, 4:
      getLikePost(page: likePostPage, size: 10)
    default:
      tableView.refreshControl?.endRefreshing()
      return
    }
    
    tableView.refreshControl?.endRefreshing()
  }
  
  private func initializeMyInfo() {
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    myPostButton.setTitleColor(.black, for: .normal)
    likePostButton.setTitleColor(.lightGray, for: .normal)
    initializeModels()
    getMyPage()
    getMyPost(page: myPostPage, size: 10)
    print(tableView.tag)
  }
  
  private func initializeModels() {
    myPostPage = 0
    myPostLastPage = false
    myPost.removeAll()
    likePostPage = 0
    likePostLastPage = false
    likePost.removeAll()
  }
  
  // 나중에 내 게시물이랑 좋아요 누른 게시물 비동기 처리해서 한번에 받아오면 좋을듯. 데이터를 받은 후에 좋아요 누른 글로 넘어가려고 하니 딜레이가 좀 있음.. 수정 필요해보인다.
  func getMyPage() {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.myPage)
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
                statusCode == 200,
              let responseData = response.data
        else {
          self.designGuestView()
          return
        }
        self.updateMyPage(json: JSON(responseData))
    }
  }
  
  func getMyPost(page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.getMyPost(page: page, size: size))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data
        else { return }
        self.updateMyPost(json: JSON(responseData))
      }
  }
  
  func getLikePost(page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(LikePostRouter.getLikePost(page: page, size: size))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data
        else { return }
        self.updateLikePost(json: JSON(responseData))
      }
  }
  
  private func updateMyPage(json: JSON) {
    myPage = MyPage(json: json)
    designLoginView()
  }
  
  private func updateMyPost(json: JSON) {
    guard json.count > 0// 만약 게시글이 30개라면?
    else {
      guard myPost.count > 0 else {
        tableView.tag = 3
        tableView.reloadData()
        return
      }
      return
    }
    tableView.tag = 1
    if json.count < 10 {  myPostLastPage = true }
    for i in 0..<json.count {
      myPost.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
    tableView.reloadData()
  }
  
  private func updateLikePost(json: JSON) {
    print("UserLikePosting Button Clicked")
    guard json.count > 0 else {
      tableView.tag = 4
      tableView.reloadData()
      return
    }
    print(json.count)
    tableView.tag = 2
    if json.count < 10 { likePostLastPage = true }
    for i in 0..<json.count {
      likePost.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
    tableView.reloadData()
  }
    
  // 로직 확인 필요
  private func deletePost(indexPath: IndexPath) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.deletePost(productIndex: myPost[indexPath.row].productIndex))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        self.myPost.removeAll()
        self.myPostPage = 0
        self.myPostLastPage = false
        self.getMyPost(page: self.myPostPage, size: 10)
      }
  }
  
  private func upPost(productIndex: Int) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.upPost(productIndex: productIndex))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          let alertController = UIAlertController(title: "이미 올리셨어요!",
                                        message: "게시글은 하루에 한 개만 올릴 수 있어요.",
                                        preferredStyle: .alert)
          let confirmAction = UIAlertAction(title: "확인", style: .default)
          alertController.addAction(confirmAction)
          self.present(alertController, animated: true)
          return
        }
        let alertController = UIAlertController(title: "게시글을 올렸어요!",
                                      message: "제일 위로 게시글이 올라갔어요!",
                                      preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true)
      }
  }
  
  private func changeSaleStatus(productIndex: Int) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.changeSaleStatus(productIndex: productIndex))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data else { return }
        print(JSON(responseData))
      }
  }
  
  private func registerXib() {
    let userPostingXib = UINib(nibName: "MyPostingCell", bundle: nil)
    tableView.register(userPostingXib, forCellReuseIdentifier: "myPostingCell")
    let likePostingXib = UINib(nibName: "UserPostingCell", bundle: nil)
    tableView.register(likePostingXib, forCellReuseIdentifier: "userPostingCell")
    let emptyPostingXib = UINib(nibName: "EmptyPostingCell", bundle: nil)
    tableView.register(emptyPostingXib, forCellReuseIdentifier: "emptyPostingCell")
  }
    
  //MARK: Button Actions
  
  @IBAction func test(_ sender: Any) {
    let url = "https://api.sugo-diger.com/user/password"
    // "id" : "userindex"
    // "password" : "password"
    // .put
    // authorization
    
    let parameter: Parameters = [
      "id" : myPage.userIndex,
      "password" : "1q2w3e4r!"
    ]
    
    let header: HTTPHeaders = [
      "Authorization" : String(keychain.get("AccessToken") ?? "")
    ]
      
    AF.request(url,
               method: .put,
               parameters: parameter,
               encoding: JSONEncoding.default,
               headers: header).response { response in
    }
  }
  
  
  @IBAction func myPostButtonClicked(_ sender: Any) {
    myPostButton.setTitleColor(.black, for: .normal)
    likePostButton.setTitleColor(.lightGray, for: .normal)
    guard myPost.count == 0 else {
      tableView.tag = 1
      tableView.reloadData()
      return
    }
    tableView.tag = 3
    tableView.reloadData()
  }
  
  @IBAction func likePostButtonClicked(_ sender: Any) {
    // 카운트가 0이면 api 호출하기
    myPostButton.setTitleColor(.lightGray, for: .normal)
    likePostButton.setTitleColor(.black, for: .normal)
    guard likePost.count == 0 else {
      tableView.tag = 2
      tableView.reloadData()
      return
    }
    getLikePost(page: likePostPage, size: 10)
  }
  
  // 게시글 수정은 API 수정 될 예정. 로직도 수정해야 함.
  @objc func modifyButtonClicked(sender: UIButton) {
    let indexPath = IndexPath(row: sender.tag, section: 0)
    let postingView = UIStoryboard(name: "PostingView", bundle: nil)
    modifyData.productIndex = myPost[indexPath.row].productIndex
    modifyData.title = myPost[indexPath.row].title
    modifyData.category = myPost[indexPath.row].category
    modifyData.price = myPost[indexPath.row].price
    guard let postingNavigationController = postingView.instantiateViewController(withIdentifier: "postingNavigationVC") as? UINavigationController else { return }
    postingNavigationController.modalPresentationStyle = .fullScreen
    postingNavigationController.navigationBar.topItem?.title = "게시글 수정"
    self.present(postingNavigationController, animated: true)
  }
  
  @objc func upPostButtonClicked(sender: UIButton) {
    let indexPath = IndexPath(row: sender.tag, section: 0)
    upPost(productIndex: myPost[indexPath.row].productIndex)
  }

  @objc func kebabMenuClicked(_ sender: UIButton) {
    // 삭제, 거래완료처리, 게시글 끌어올리기
    let indexPath = IndexPath(row: sender.tag, section: 0)
    print(indexPath)
    let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let changeSaleStatusAction = UIAlertAction(title: "판매 완료로 변경하기", style: .default) { _ in
      self.changeSaleStatusAlert(title: "판매 상태를 바꾸시겠어요?",
                                 message: "확인을 누르시면, 글의 상태가 판매 완료로 변경되요!",
                                 indexPath: indexPath)
    }
    let deleteAction = UIAlertAction(title: "게시글 삭제", style: .destructive) { alert in
      self.deleteAlert(title: "게시글을 정말 삭제하시겠어요?", message: "", indexPath: indexPath)
    }
    let cancelAction = UIAlertAction(title: "닫기", style: .cancel)
    actionSheetController.addAction(changeSaleStatusAction)
    actionSheetController.addAction(deleteAction)
    actionSheetController.addAction(cancelAction)
    present(actionSheetController, animated: true)
  }
  
  @objc func settingButtonClicked(_ sender: UIButton) {
    let settingView = UIStoryboard(name: "SettingView", bundle: nil)
    guard let settingContrller = settingView.instantiateViewController(withIdentifier: "settingVC")
            as? SettingController
    else {return}
    self.navigationController?.pushViewController(settingContrller, animated: true)
  }
    
  //MARK: Design Functions
  
  private func customRightBarButton() {
    let settingButton = self.navigationItem.makeSFSymbolButton(self,
                                                               action: #selector(settingButtonClicked),
                                                               symbolName: "gearshape")
    self.navigationItem.rightBarButtonItem = settingButton
  }
  
  private func deleteAlert(title: String, message: String, indexPath: IndexPath) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
      self.deletePost(indexPath: indexPath)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true)
  }
  
  private func changeSaleStatusAlert(title: String, message: String, indexPath: IndexPath) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let changeAction = UIAlertAction(title: "변경", style: .default) { _ in
      self.changeSaleStatus(productIndex: self.myPost[indexPath.row].productIndex)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    alert.addAction(changeAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true)
  }

  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
  private func designLoginView() {
    tableView.isHidden = false
    myPostButton.isHidden = false
    likePostButton.isHidden = false
    
    guestLabel.text = ""
    userImage.tintColor = colorLiteralGreen
    
    userNicknameLabel.text = "오늘도 수고하세요! \(myPage.userNickname)님!"
    userNicknameLabel.textColor = .black
    
    userMannerGradeLabel.text = myPage.userMannerGrade
    userMannerGradeLabel.textColor = colorLiteralGreen
    
    userEvaluationCountLabel.text = "\(myPage.userEvaluationCount)"
    userEvaluationCountLabel.textColor = colorLiteralGreen
    
    userTradeCountLabel.text = "\(myPage.userTradeCount)"
    userTradeCountLabel.textColor = colorLiteralGreen
  }
  
  private func designGuestView() {
    tableView.isHidden = true
    myPostButton.isHidden = true
    likePostButton.isHidden = true
    
    userImage.tintColor = .lightGray
    guestLabel.text = "로그인이 필요해요!"
    userNicknameLabel.text = "게스트 상태입니다."
    userNicknameLabel.textColor = .darkGray
    userMannerGradeLabel.text = "-"
    userMannerGradeLabel.textColor = .darkGray
    userEvaluationCountLabel.text = "-"
    userEvaluationCountLabel.textColor = .darkGray
    userTradeCountLabel.text = "-"
    userTradeCountLabel.textColor = .darkGray
  }
  
}
