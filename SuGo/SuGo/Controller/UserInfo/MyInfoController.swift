//
//  UserInfoController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/14.
//

import UIKit

import Alamofire
import KeychainSwift
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
    
    //MARK: Functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        
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
                                        status: myPosting["status"].boolValue,
                                        imageLink: myPosting["imageLink"].stringValue,
                                        contactPlace: myPosting["contactPlace"].stringValue,
                                        updatedAt: myPosting["updatedAt"].stringValue)
            
            userPosting.append(getData)
        }
        
//        for i in 0..<json["likePosting"].count {
//
//        }
        print(userPosting)
    }
    
    
    
    //MARK: Button Actions
    
    //MARK: Design Functions
    
    private func designLoginView() {
        
        userNicknameLabel.text = myPage.userNickname
        userMannerGradeLabel.text = myPage.userMannerGrade
        userEvaluationCountLabel.text = "\(myPage.userEvaluationCount)"
        userTradeCountLabel.text = "\(myPage.userTradeCount)"
        
    }
    

}

extension MyInfoController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPosting.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }


}
