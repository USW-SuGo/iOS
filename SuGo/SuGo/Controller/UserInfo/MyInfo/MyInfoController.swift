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


// tag 1 - 판매 중 / 2 - 판매완료 / 3 - 좋아요 누른 글
// else label -> isHidden false
class MyInfoController: UIViewController {

  //MARK: IBOutlets
    
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var userNicknameLabel: UILabel!
  @IBOutlet weak var userMannerGradeLabel: UILabel!
  @IBOutlet weak var userEvaluationCountLabel: UILabel!
  @IBOutlet weak var userTradeCountLabel: UILabel!
  @IBOutlet weak var myPostButton: UIButton!
  @IBOutlet weak var soldOutPostButton: UIButton!
  @IBOutlet weak var likePostButton: UIButton!
  @IBOutlet weak var guestLabel: UILabel!
  
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
  
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let keychain = KeychainSwift()
  var myPage = MyPage()
  var myPagePosting = MyPagePost()
  var myPost: [MyPagePost] = []
  var mySoldOutPost: [MyPagePost] = []
  var likePost: [MyPagePost] = []
  let modifyData = ModifyProduct.shared
  var myPostPage = 0
  var myPostLastPage = false
  var mySoldOutPage = 0
  var mySoldOutLastPage = false
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
    initializeMyInfo()
    customRightBarButton()
    customBackButton()
    registerXib()
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("My Info View Will Appear")
//    initializeMyInfo()
  }
  
  //MARK: Functions
  
  @objc
  private func callRefresh() {
    tableView.refreshControl?.beginRefreshing()
    switch tableView.tag {
    case 1:
      initializePostData(page: &myPostPage,
                         lastPage: &myPostLastPage,
                         post: &myPost)
      getPost(api: PostRouter.getMyPost(page: myPostPage, size: 10),
              updatePost: updateMyPost)
    case 2:
      initializePostData(page: &mySoldOutPage,
                         lastPage: &mySoldOutLastPage,
                         post: &mySoldOutPost)
      getPost(api: PostRouter.getMySoldOutPost(page: mySoldOutPage, size: 10),
              updatePost: updateMySoldOutPost)
    case 3:
      initializePostData(page: &likePostPage,
                         lastPage: &likePostLastPage,
                         post: &likePost)
      getPost(api: LikePostRouter.getLikePost(page: likePostPage, size: 10),
              updatePost: updateLikePost)
    default:
      tableView.refreshControl?.endRefreshing()
      return
    }
    tableView.refreshControl?.endRefreshing()
  }
  
  private func initializeMyInfo() {
    tableView.refreshControl = refresh
    tableView.separatorStyle = .none
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    getMyPage()
    callGetPost()
    tableView.tag = 1
  }
  
  // 게시물 데이터들을 초기화 해줌. 유저가 호출한 페이지 / 무한 스크롤 / 해당 포스트(판매 중 / 완료 / 좋아요)
  func initializePostData(page: inout Int,
                                  lastPage: inout Bool,
                                  post: inout [MyPagePost]) {
    page = 0
    lastPage = false
    post.removeAll()
  }
  
  func callGetPost() {
    getPost(api: PostRouter.getMyPost(page: myPostPage, size: 10),
            updatePost: updateMyPost)
    getPost(api: PostRouter.getMySoldOutPost(page: mySoldOutPage, size: 10),
            updatePost: updateMySoldOutPost)
    getPost(api: LikePostRouter.getLikePost(page: likePostPage, size: 10),
            updatePost: updateLikePost)
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
  
  private func updateMyPage(json: JSON) {
    myPage = MyPage(json: json)
    designLoginView()
  }

  func getPost(api: URLRequestConvertible, updatePost: @escaping (JSON) -> ()) {
    var json: JSON = JSON.null
    AlamofireManager
      .shared
      .session
      .request(api)
      .validate()
      .response { response in
        guard let statusCode = response.response?.statusCode,
              statusCode == 200,
              let responseData = response.data
        else { return }
        json = JSON(responseData)
        updatePost(json)
      }
  }
  
  //판매 중
  func updateMyPost(json: JSON) {
    guard json.count > 0 else { // 만약 게시글이 30개라면?
      guard myPost.count > 0 else { // 게시글이 아예 없을 경우.
        // 테이블뷰 가리고 유저에게 알림
        return
      }
      return
    }
    if json.count < 10 {  myPostLastPage = true } // 10개 미만으로 떨어질 경우 lastPage
    for i in 0..<json.count {
      myPost.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
    tableView.reloadData()
  }
  
  // 판매 완료
  func updateMySoldOutPost(json: JSON) {
    guard json.count > 0 else {
      // 유저에게 알림이 여기서 필요하지 않음. 왜?
      // 판매 중 탭은 디폴트 탭이기에 바로 체크를 해주어야 하지만
      // 다른 탭에서 체크를 할 경우 디폴트 탭에 데이터가 있음에도 테이블뷰가 가려질 것임.
      return }
    if json.count < 10 { mySoldOutLastPage = true }
    for i in 0..<json.count {
      mySoldOutPost.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
    // tableView reloadData가 필요 없는 이유
    // 마이페이지 클릭 시 -> 모든 데이터 받아옴
    // 유저가 다른 탭으로 변경할 경우 reloadData 호출함.
  }
  
  // 좋아요 누른 글
  func updateLikePost(json: JSON) {
    guard json.count > 0 else {
      return
    }
    if json.count < 10 { likePostLastPage = true }
    for i in 0..<json.count {
      likePost.append(myPagePosting.jsonToMyPagePosting(json: json[i]))
    }
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
//        self.getMyPost(page: self.myPostPage, size: 10)
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
  
  @IBAction func myPostButtonClicked(_ sender: Any) {
    myPostButton.setTitleColor(.black, for: .normal)
    soldOutPostButton.setTitleColor(.lightGray, for: .normal)
    likePostButton.setTitleColor(.lightGray, for: .normal)
    tableView.tag = 1
    tableView.reloadData()

  }
  
  @IBAction func soldOutPostButtonClicked(_ sender: Any) {
    myPostButton.setTitleColor(.lightGray, for: .normal)
    soldOutPostButton.setTitleColor(.black, for: .normal)
    likePostButton.setTitleColor(.lightGray, for: .normal)
    tableView.tag = 2
    tableView.reloadData()
  }
  
  @IBAction func likePostButtonClicked(_ sender: Any) {
    myPostButton.setTitleColor(.lightGray, for: .normal)
    soldOutPostButton.setTitleColor(.lightGray, for: .normal)
    likePostButton.setTitleColor(.black, for: .normal)
    tableView.tag = 3
    tableView.reloadData()
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
    soldOutPostButton.isHidden = false
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
    soldOutPostButton.isHidden = true
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
