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
  var myPagePosting = MyPagePosting()
  var userPosting: [MyPagePosting] = []
  var userLikePosting: [MyPagePosting] = []
  let modifyData = ModifyProduct.shared
  var userPostingPage = 0
  var userPostingLastPage = false
  var userLikePostingPage = 0
  var userLikePostingLastPage = false
  
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
      getMyPage(page: userPostingPage, size: 10, posting: "myPostings")
    case 2, 4:
      getMyPage(page: userLikePostingPage, size: 10, posting: "likePostings")
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
    getMyPage(page: userPostingPage, size: 10, posting: "myPostings")
    print(tableView.tag)
  }
  
  private func initializeModels() {
    userPostingPage = 0
    userPostingLastPage = false
    userPosting.removeAll()
    userLikePostingPage = 0
    userPostingLastPage = false
    userLikePosting.removeAll()
  }
  
  // 나중에 내 게시물이랑 좋아요 누른 게시물 비동기 처리해서 한번에 받아오면 좋을듯. 데이터를 받은 후에 좋아요 누른 글로 넘어가려고 하니 딜레이가 좀 있음.. 수정 필요해보인다.
  func getMyPage(page: Int, size: Int, posting: String) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.myPage(page: page, size: size))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
                statusCode == 200,
              let responseData = response.data
        else {
          self.designGuestView()
          return
        }
        // 초기화만 된 상태일 경우 메소드 호출
        if self.myPage.userIndex == "" {
            self.updateMyPage(json: JSON(responseData))
        }
        print("page: \(page), size: \(size), count: \(JSON(responseData)[posting].count)")
        posting == "myPostings" ?
        self.updateUserPosting(json: JSON(responseData)[posting]) :
        self.updateUserLikePosting(json: JSON(responseData)[posting])
    }
  }
  
  private func updateMyPage(json: JSON) {
    myPage.updateMyPage(json: json)
    designLoginView()
  }
  
  private func updateUserPosting(json: JSON) {
    guard json.count > 0// 만약 게시글이 30개라면?
    else {
      guard userPosting.count > 0 else {
        tableView.tag = 3
        tableView.reloadData()
        return
      }
      return
    }
    tableView.tag = 1
    if json.count < 10 {  userPostingLastPage = true }
    for i in 0..<json.count {
      userPosting.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
    tableView.reloadData()
  }
  
  private func updateUserLikePosting(json: JSON) {
    print("UserLikePosting Button Clicked")
    guard json.count > 0 else {
      tableView.tag = 4
      tableView.reloadData()
      return
    }
    print(json.count)
    tableView.tag = 2
    if json.count < 10 { userLikePostingLastPage = true }
    for i in 0..<json.count {
      userLikePosting.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
    tableView.reloadData()
  }
    
  // 로직 확인 필요
  private func deletePost(indexPath: IndexPath) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.deletePost(productIndex: userPosting[indexPath.row].productIndex))
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        self.userPosting.removeAll()
        self.userPostingPage = 0
        self.userPostingLastPage = false
        self.getMyPage(page: self.userPostingPage, size: 10, posting: "myPostings")
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
    guard userPosting.count == 0 else {
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
    guard userLikePosting.count == 0 else {
      tableView.tag = 2
      tableView.reloadData()
      return
    }
    getMyPage(page: userLikePostingPage, size: 10, posting: "likePostings")
  }
  
  // 게시글 수정은 API 수정 될 예정. 로직도 수정해야 함.
  @objc func modifyButtonClicked(sender: UIButton) {
    let indexPath = IndexPath(row: sender.tag, section: 0)
    let postingView = UIStoryboard(name: "PostingView", bundle: nil)
    modifyData.productIndex = userPosting[indexPath.row].productIndex
    modifyData.title = userPosting[indexPath.row].title
    modifyData.category = userPosting[indexPath.row].category
    modifyData.price = userPosting[indexPath.row].price
    guard let postingNavigationController = postingView.instantiateViewController(withIdentifier: "postingNavigationVC") as? UINavigationController else { return }
    postingNavigationController.modalPresentationStyle = .fullScreen
    postingNavigationController.navigationBar.topItem?.title = "게시글 수정"
    self.present(postingNavigationController, animated: true)
  }
  
  @objc func upPostButtonClicked(sender: UIButton) {
    let indexPath = IndexPath(row: sender.tag, section: 0)
    AlamofireManager
      .shared
      .session
      .request(PostRouter.upPost(productIndex: userPosting[indexPath.row].productIndex))
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

  @objc func kebabMenuClicked(_ sender: UIButton) {
    // 삭제, 거래완료처리, 게시글 끌어올리기
    let indexPath = IndexPath(row: sender.tag, section: 0)
    print(indexPath)
    let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "게시글 삭제", style: .destructive) { alert in
      self.customAlert(title: "게시글을 정말 삭제하시겠어요?", message: "", indexPath: indexPath)
    }
    let cancelAction = UIAlertAction(title: "닫기", style: .cancel)
    actionSheetController.addAction(deleteAction)
    actionSheetController.addAction(cancelAction)
    present(actionSheetController, animated: true)
  }
    
  //MARK: Design Functions
  
  private func customAlert(title: String, message: String, indexPath: IndexPath) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { alert in
      self.deletePost(indexPath: indexPath)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true, completion: nil)
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
