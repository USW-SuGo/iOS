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
    switch tableView.tag{
    case 1:
      userPostingPage = 0
      userPostingLastPage = false
      userPosting.removeAll()
      getMyPage(page: userPostingPage, size: 10)
    case 2:
      userLikePostingPage = 0
      userLikePostingLastPage = false
      userLikePosting.removeAll()
      getLikePosting(page: userLikePostingPage, size: 10)
    case 3:
      tableView.refreshControl?.endRefreshing()
      return
    case 4:
      tableView.refreshControl?.endRefreshing()
      return
    default:
      tableView.refreshControl?.endRefreshing()
      return
    }
    tableView.refreshControl?.endRefreshing()
  }
  
  private func initializeMyInfo() {
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UITableView.automaticDimension
    userPostingPage = 0
    userPostingLastPage = false
    userLikePostingPage = 0
    userLikePostingLastPage = false
    userPosting.removeAll()
    userLikePosting.removeAll()
    getMyPage(page: userPostingPage, size: 10)
    getLikePosting(page: userLikePostingPage, size: 10)
    print(tableView.tag)
  }
  
  private func customUpdateAt(day: Int) -> String {
    switch day{
    case 0:
      return "오늘"
    case 1:
      return "어제"
    case 2..<7:
      return "\(day)일 전"
    case 7..<30:
      return "\(day / 7)주 전"
    case 30...:
      return "\(day / 30)달 전"
    default:
      return ""
    }    
  }
    
  private func getMyPage(page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.myPage(page: page, size: size))
      .validate()
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else {
          self.designGuestView()
          return
        }
        
        if self.myPage.userIndex == "" {
            self.updateMyPage(json: JSON(response.data ?? ""))
        }
        
        self.updateUserPosting(json: JSON(response.data ?? "")["myPosting"])
    }
  }
  
  private func getLikePosting(page: Int, size: Int) {
    AlamofireManager
      .shared
      .session
      .request(PageRouter.myPage(page: page, size: size))
      .validate()
      .responseJSON { response in
        guard let statusCode = response.response?.statusCode, statusCode == 200 else { return }
        self.updateUserLikePosting(json: JSON(response.data ?? "")["likePosting"])
      }
  }
    // if user login
  private func updateMyPage(json: JSON) {
    myPage.userIndex = json["id"].stringValue
    myPage.userEmail = json["email"].stringValue
    myPage.userNickname = json["nickname"].stringValue
    myPage.userMannerGrade = json["mannerGrade"].stringValue
    myPage.userEvaluationCount = json["countMannerEvaluation"].intValue
    myPage.userTradeCount = json["countTradeAttempt"].intValue
    designLoginView()
  }
  
  private func updateUserPosting(json: JSON) {
    guard json.count > 0 else {
      tableView.tag = 3
      tableView.reloadData()
      return
    }
    tableView.tag = 1
    if json.count < 10 {
      userPostingLastPage = true
    }
    
    for i in 0..<json.count {
      let myPosting = json[i]
      
      let postDate = myPosting["updatedAt"].stringValue.components(separatedBy: "T")[0]
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.date(from: postDate) ?? nil
      let interval = Date().timeIntervalSince(startDate ?? Date())
      let intervalDays = Int((interval) / 86400)
      
      let getData = MyPagePosting(productIndex: myPosting["id"].intValue,
                                  title: myPosting["title"].stringValue,
                                  price: myPosting["price"].stringValue,
                                  decimalWon: decimalWon(price: myPosting["price"].intValue),
                                  category: myPosting["category"].stringValue,
                                  status: myPosting["status"].boolValue,
                                  imageLink: myPosting["imageLink"].stringValue,
                                  contactPlace: myPosting["contactPlace"].stringValue,
                                  updatedAt: customUpdateAt(day: intervalDays))
      userPosting.append(getData)
    }
    tableView.reloadData()
  }
  
  private func updateUserLikePosting(json: JSON) {
    guard json.count > 0 else {
      tableView.tag = 4
      tableView.reloadData()
      return
    }
    tableView.tag = 2
    if json.count < 10 {
      userLikePostingLastPage = true
    }
    
    for i in 0..<json.count {
      let likePosting = json[i]
      let postDate = likePosting["updatedAt"].stringValue.components(separatedBy: "T")[0]
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let startDate = dateFormatter.date(from: postDate) ?? nil
      let interval = Date().timeIntervalSince(startDate ?? Date())
      let intervalDays = Int((interval) / 86400)
      let getData = MyPagePosting(productIndex: likePosting["id"].intValue,
                                  title: likePosting["title"].stringValue,
                                  price: likePosting["price"].stringValue,
                                  decimalWon: decimalWon(price: likePosting["price"].intValue),
                                  category: likePosting["category"].stringValue,
                                  status: likePosting["status"].boolValue,
                                  imageLink: likePosting["imageLink"].stringValue,
                                  contactPlace: likePosting["contactPlace"].stringValue,
                                  updatedAt: customUpdateAt(day: intervalDays))
      userLikePosting.append(getData)
    }
    tableView.reloadData()
  }
    
  private func deletePost(indexPath: IndexPath) {
    userPostingPage = 0
    AlamofireManager
      .shared
      .session
      .request(PostRouter.deletePost(productIndex: userPosting[indexPath.row].productIndex))
      .validate()
      .responseJSON { response in
        self.userPosting.removeAll()
        self.getMyPage(page: self.userPostingPage, size: 10)
      }
  }
    
    //MARK: Button Actions
    
  @IBAction func myPostButtonClicked(_ sender: Any) {
    if userPosting.count > 0 {
      tableView.tag = 1
    } else {
      tableView.tag = 3
    }
    myPostButton.setTitleColor(.black, for: .normal)
    likePostButton.setTitleColor(.lightGray, for: .normal)
    tableView.reloadData()
  }
  
  @IBAction func likePostButtonClicked(_ sender: Any) {
    if userLikePosting.count > 0 {
      tableView.tag = 2
    } else {
      tableView.tag = 4
    }
    myPostButton.setTitleColor(.lightGray, for: .normal)
    likePostButton.setTitleColor(.black, for: .normal)
    tableView.reloadData()
  }
  
  @objc func modifyButtonClicked(sender: UIButton) {
    let indexPath = IndexPath(row: sender.tag, section: 0)
    let postingView = UIStoryboard(name: "PostingView", bundle: nil)
    modifyData.productIndex = userPosting[indexPath.row].productIndex
    modifyData.title = userPosting[indexPath.row].title
    modifyData.category = userPosting[indexPath.row].category
    modifyData.price = userPosting[indexPath.row].price
    print(userPosting[indexPath.row].productIndex)
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
      .responseJSON { response in
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
  
  func decimalWon(price: Int) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: price))! + "원"
    
    return result
  }
  
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
    
  private func registerXib() {
    let userPostingXib = UINib(nibName: "UserPostingCell", bundle: nil)
    tableView.register(userPostingXib, forCellReuseIdentifier: "userPostingCell")
    let likePostingXib = UINib(nibName: "LikePostingCell", bundle: nil)
    tableView.register(likePostingXib, forCellReuseIdentifier: "likePostingCell")
    let emptyPostingXib = UINib(nibName: "EmptyPostingCell", bundle: nil)
    tableView.register(emptyPostingXib, forCellReuseIdentifier: "emptyPostingCell")
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

extension MyInfoController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch tableView.tag {
    case 1:
      return 138
    case 2:
      return 178
    case 3:
      return 510
    case 4:
      return 510
    default:
      return UITableView.automaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    if tableView.tag == 1 {
      let lastIndex = userPosting.count - 2
      if indexPath.row == lastIndex {
        userPostingPage += 1
        if !userPostingLastPage {
          print("infinite scroll work")
          getMyPage(page: userPostingPage, size: 10)
        }
      }
    } else if tableView.tag == 2 {
      let lastIndex = userLikePosting.count - 2
      if indexPath.row == lastIndex {
        userLikePostingPage += 1
        if !userLikePostingLastPage {
          getLikePosting(page: userLikePostingPage, size: 10)
        }
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tableView.tag {
    case 1:
      return userPosting.count
    case 2:
      return userLikePosting.count
    case 3:
      return 1
    case 4:
      return 1
    default:
      return 1
    }
  }

  // 테이블 뷰 데이터 없을 때 보여줘야 할 텍스트 분기 필요함.
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView.tag {
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "userPostingCell",
                                               for: indexPath) as! UserPostingCell
      if userPosting.count > 0 { // indexPath out of range 방지 위함.
        if let url = URL(string: userPosting[indexPath.row].imageLink) {
          cell.productImage.kf.indicatorType = .activity
          cell.productImage.kf.setImage(with: url,
                                        placeholder: nil,
                                        options: [
                                          .transition(.fade(0.1)),
                                          .cacheOriginalImage
                                        ],
                                        progressBlock: nil)
        }
        cell.productImage.contentMode = .scaleAspectFill
        cell.productImage.layer.cornerRadius = 6.0
        cell.titleLabel.text = userPosting[indexPath.row].title
        cell.nicknameLabel.text = "내가 쓴 글"
        cell.placeUpdateCategoryLabel.text = "\(userPosting[indexPath.row].contactPlace) | \(userPosting[indexPath.row].updatedAt) | \(userPosting[indexPath.row].category)"
        cell.priceLabel.text = userPosting[indexPath.row].decimalWon
        cell.kebabMenuButton.tag = indexPath.row
        cell.kebabMenuButton.addTarget(self,
                                       action: #selector(kebabMenuClicked),
                                       for: .touchUpInside)
        cell.modifyButton.tag = indexPath.row
        cell.modifyButton.addTarget(self,
                                    action: #selector(modifyButtonClicked),
                                    for: .touchUpInside)
        cell.upPostButton.tag = indexPath.row
        cell.upPostButton.addTarget(self,
                                    action: #selector(upPostButtonClicked),
                                    for: .touchUpInside)
        cell.selectionStyle = .none
      }
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(withIdentifier: "likePostingCell",
                                                      for: indexPath) as! LikePostingCell
      print(userLikePosting)
      if userLikePosting.count > 0 {
        if let url = URL(string: userLikePosting[indexPath.row].imageLink) {
          cell.productImage.kf.indicatorType = .activity
          cell.productImage.kf.setImage(with: url,
                                        placeholder: nil,
                                        options: [
                                          .transition(.fade(0.1)),
                                          .cacheOriginalImage
                                        ],
                                        progressBlock: nil)
        }
        cell.productImage.contentMode = .scaleAspectFill
        cell.placeUpdateCategoryLabel.text = "\(userLikePosting[indexPath.row].contactPlace) | \(userLikePosting[indexPath.row].updatedAt) | \(userLikePosting[indexPath.row].category)"
        cell.titleLabel.text = userLikePosting[indexPath.row].title
        cell.priceLabel.text = userLikePosting[indexPath.row].decimalWon
      }
      return cell
    case 3:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "emptyPostingCell",
                                                     for: indexPath) as? EmptyPostingCell else
      { return UITableViewCell() }
      cell.titleLabel.text = "아직 작성한 게시글이 없습니다."
      cell.explanationLabel.text = "거래하고 싶은 물품들을 수고에 올려보세요!"
      return cell
    case 4:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "emptyPostingCell",
                                                     for: indexPath) as? EmptyPostingCell else
      { return UITableViewCell() }
      cell.titleLabel.text = "아직 좋아요 누른 글이 없습니다."
      cell.explanationLabel.text = "관심가는 상품에 좋아요를 눌러보세요!"
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView.tag == 1 {
      let postView = UIStoryboard(name: "PostView", bundle: nil)
      guard let postController = postView.instantiateViewController(withIdentifier: "postVC")
              as? PostController
      else { return }
      postController.productPostId = userPosting[indexPath.row].productIndex
      navigationController?.pushViewController(postController, animated: true)
    }
  }

}
