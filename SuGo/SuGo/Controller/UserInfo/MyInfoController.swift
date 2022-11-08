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

class MyInfoController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userMannerGradeLabel: UILabel!
    @IBOutlet weak var userEvaluationCountLabel: UILabel!
    @IBOutlet weak var userTradeCountLabel: UILabel!
    
    //MARK: Properties
    
    let keychain = KeychainSwift()
    var myPage = MyPage()
    var userPosting: [MyPagePosting] = []
    var likePosting: [MyPagePosting] = []
    var testUser = [1, 2, 3]
    var testLike = [1, 2]
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tag = 1
        tableView.separatorStyle = .none
        registerXib()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        print("My Info")
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
                    
                    print(JSON(response.data))
                    
                    if self.myPage.userIndex == "" {
                        self.updateMyPage(json: JSON(response.data ?? ""))
                    }
                    self.updateMyPagePosting(json: JSON(response.data ?? ""))
                    
                    
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
                
            let getData = MyPagePosting(userIndex: myPosting["id"].stringValue,
                                        title: myPosting["title"].stringValue,
                                        price: myPosting["price"].stringValue,
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
    
    
    
    //MARK: Button Actions
    
    @IBAction func myPostButtonClicked(_ sender: Any) {
    
        tableView.tag = 1
        tableView.reloadData()
        
    }
    
    @IBAction func likePostButtonClicked(_ sender: Any) {
        
        tableView.tag = 2
        tableView.reloadData()
        
    }
    
    //MARK: Design Functions
    
    private func registerXib() {
        
        let userPostingXib = UINib(nibName: "UserPostingCell", bundle: nil)
        tableView.register(userPostingXib, forCellReuseIdentifier: "userPostingCell")
        
        let likePostingXib = UINib(nibName: "LikePostingCell", bundle: nil)
        tableView.register(likePostingXib, forCellReuseIdentifier: "likePostingCell")
        
    }
    
    private func designLoginView() {
        
        userNicknameLabel.text = "\(myPage.userNickname)님 ! 반갑습니다."
        userMannerGradeLabel.text = myPage.userMannerGrade
        userEvaluationCountLabel.text = "\(myPage.userEvaluationCount)"
        userTradeCountLabel.text = "\(myPage.userTradeCount)"
        
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
            
            
            cell.selectionStyle = .none
            
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
