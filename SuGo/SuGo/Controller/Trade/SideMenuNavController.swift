//
//  SideMenuController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/28.
//

import UIKit

import SideMenu
import Alamofire
import KeychainSwift

class SideMenuNavController: SideMenuNavigationController {

    var testSideMenu = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftSide = true
    }

}

// 리프레쉬 토큰 만료 시 검증할 방법 구현 필요
class SideMenuController: UIViewController{
    
    //MARK: IBOutlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userStateLabel: UILabel!
    @IBOutlet weak var loginAndLogoutButton: UIButton!
    @IBOutlet weak var signUpAndUserInfoButton: UIButton!
    @IBOutlet weak var noticeButton: UIButton!
    
    //MARK: Properties
    
    let keychain = KeychainSwift()
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    
    //MARK: Functions
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(keychain.get("AccessToken"))
        print("sideViewWillAppear")
        buttonTitleChange()
    }
    
    //MARK: Button Actions
    
    @IBAction func loginAndLogoutButtonClicked(_ sender: Any) {
          
      if keychain.get("AccessToken") == nil {
          
          let loginViewStoryboard  = UIStoryboard(name: "LoginView", bundle: nil)
          let nextViewController = loginViewStoryboard.instantiateViewController(withIdentifier: "loginVC") as! LoginController
          nextViewController.modalPresentationStyle = .fullScreen
          present(nextViewController, animated: true, completion: nil)
          
      } else { // alert 실행 후 확인버튼 누를 시 로그인
          
          keychain.clear()
          self.dismiss(animated: true)
          
      }
    }
    
    @IBAction func signUpAndUserInfoButtonClicked(_ sender: Any) {
        
      if keychain.get("AccessToken") == nil {
          
        let signUpViewStoryboard = UIStoryboard(name: "SignUpView", bundle: nil)
        let nextViewController = signUpViewStoryboard.instantiateViewController(withIdentifier: "signupVC") as! SignUpController
        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true, completion: nil)
        
      } else {
          
        let myInfoViewStoryboard = UIStoryboard(name: "MyInfoView", bundle: nil)
        let myInfoViewController = myInfoViewStoryboard.instantiateViewController(withIdentifier: "myInfoVC") as! MyInfoController
        myInfoViewController.modalPresentationStyle = .fullScreen
        present(myInfoViewController, animated: true, completion: nil)
          
      }
    }
    
    //MARK: Design Functions
    
    private func buttonTitleChange() {
        
        
      if keychain.get("AccessToken") == nil {
          
        userImageView.tintColor = UIColor.lightGray
        userStateLabel.text = "비 로그인 상태입니다."
        loginAndLogoutButton.setTitle("로그인", for: .normal)
        signUpAndUserInfoButton.setTitle("회원가입", for: .normal)
          
      } else {
          
        userImageView.tintColor = colorLiteralGreen
        userStateLabel.text = "오늘도 수고하세요 !"
        loginAndLogoutButton.setTitle("로그아웃", for: .normal)
        signUpAndUserInfoButton.setTitle("내 정보", for: .normal)
          
      }
    }
  
}

