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
// 2-2. 하단에 로그인 시 볼 수 있도록 불투명 처리. 로그인 버튼 추가

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
    
  let keychain = KeychainSwift()
  var myPage = MyPage()
  var userPosting: [MyPagePosting] = []
  var likePosting: [MyPagePosting] = []
  var testUser = [1, 2, 3]
  var testLike = [1, 2]
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  let modifyData = ModifyProduct.shared
  // red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1
  
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tag = 1
        tableView.separatorStyle = .none
        registerXib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        print("My Info View Will Appear")
        
        userPosting.removeAll()
        getMyPage(page: 0, size: 10)
        
    }
    
    private func getMyPage(page: Int, size: Int) {
        
        AlamofireManager
            .shared
            .session
            .request(PageRouter.myPage(page: page, size: size))
            .validate()
            .responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    
                    
                    
                    if self.myPage.userIndex == "" {
                        self.updateMyPage(json: JSON(response.data ?? ""))
                    }
                    self.updateMyPagePosting(json: JSON(response.data ?? ""))
                    
                } else {
                    
                    self.designGuestView()
                    
                }
                
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
    
    private func updateMyPagePosting(json: JSON) {
        
        for i in 0..<json["myPosting"].count {
            
            let myPosting = json["myPosting"][i]
                
            let getData = MyPagePosting(productIndex: myPosting["id"].intValue,
                                        title: myPosting["title"].stringValue,
                                        price: myPosting["price"].stringValue,
                                        decimalWon: decimalWon(price: myPosting["price"].intValue),
                                        category: myPosting["category"].stringValue,
                                        status: myPosting["status"].boolValue,
                                        imageLink: myPosting["imageLink"].stringValue,
                                        contactPlace: myPosting["contactPlace"].stringValue,
                                        updatedAt: myPosting["updatedAt"].stringValue)
            
            userPosting.append(getData)
        }
        
//        for i in 0..<json["likePosting"].count {
//
//        }
        tableView.reloadData()

    }
    
  private func deletePost(indexPath: IndexPath) {
    AlamofireManager
      .shared
      .session
      .request(PostRouter.deletePost(productPostId: userPosting[indexPath.row].productIndex))
      .validate()
      .responseJSON { response in
        
        self.userPosting.removeAll()
        self.getMyPage(page: 0, size: 10)
      }
  }
    
    //MARK: Button Actions
    
  @IBAction func myPostButtonClicked(_ sender: Any) {
  
      tableView.tag = 1
      tableView.reloadData()
      
  }
  
  @IBAction func likePostButtonClicked(_ sender: Any) {
      
      tableView.tag = 2
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
  }

  @objc func kebabMenuClicked(_ sender: UIButton) {
    
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
        return 180.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return userPosting.count
        } else {
            return testLike.count
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if tableView.tag == 1 {
              
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
          
          cell.selectionStyle = .none
        }

        
        return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "likePostingCell",
                                                          for: indexPath) as! LikePostingCell
            
            print(testLike[indexPath.row])
            
            return cell
        }
                
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select Cell")
    }

}
