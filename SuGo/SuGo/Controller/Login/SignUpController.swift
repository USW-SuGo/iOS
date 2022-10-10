//
//  SignUpController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/10.
//

import UIKit

import Alamofire
import SwiftyJSON

// 회원가입 로직
// 1. 아이디 형식 확인 및 중복확인
// 2. 비밀번호 형식 확인
// 3. 2차 비밀번호 일치 판별
// 4. 이메일 중복 확인
// 5. 완료와 동시에 인증메일 전송
// 텍스트 변경을 실시간으로 확인해주어야 함. 예를 들어 이메일 중복확인 이후 텍스트가 변경되는 경우를 캐치 해야 함.


class SignUpController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var idBottomLine: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordBottomLine: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    //MARK: Properties
    
    let loginModel = LoginModel()
    var loginIsValid = false
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.addTarget(self,
                              action: #selector(idTextFieldisValid),
                              for: .editingChanged)
        passwordTextField.addTarget(self,
                                    action: #selector(passwordTextFieldisValid),
                                    for: .editingChanged)
        confirmPasswordTextField.addTarget(self,
                                           action: #selector(confirmPasswordTextFieldisValid),
                                           for: .editingChanged)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @objc func idTextFieldisValid(_ sender: UITextField) { // id 정규표현식 확인
        
        guard let id = idTextField.text, !id.isEmpty else { return }
        
        //1. 아이디 형식 체크 후 일치하지 않을 경우 경고문 ON
        if loginModel.isValidId(id: id) {
            // view를 중복으로 띄워주지 않기 위함.(경고문)
            loginIsValid = false
            idBottomLine.layer.backgroundColor = UIColor.black.cgColor
            
        } else {
            
            idBottomLine.layer.backgroundColor = UIColor.red.cgColor
            
            // 최초 1회 띄우기, 장치 걸지 않을 시 중복으로 뷰가 쌓임
            if loginIsValid == false {
                loginIsValid = true
                
            }
        }
    }
    
    @objc func passwordTextFieldisValid(_ sender: UITextField) { // password 정규표현식
        
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        // 정규표현식
        
        if loginModel.isValidPassword(pwd: password) {
            
            print("print : 정규표현식 부합")
            passwordBottomLine.layer.backgroundColor = UIColor.black.cgColor
            
        } else {
            
            passwordBottomLine.layer.backgroundColor = UIColor.red.cgColor
            
            if passwordTextField.text?.count ?? 0 < 8 {
                print("print: 8글자 이하, 정규표현식 불일치")
            } else {
                print("print : 8글자 이상, 정규표현식 불일치")
            }
        
        }
        
        if confirmPasswordTextField.text?.count ?? 0 > 0 && password != confirmPasswordTextField.text {
            // 2차 비밀번호 불일치 출력
            
            print("print : 2차 비밀번호까지 입력 후 1차 비밀번호 변경 시 불일치")
            
        }
        
    }
    
    @objc func confirmPasswordTextFieldisValid(_ sender: UITextField) {
        
        guard let password = confirmPasswordTextField.text, !password.isEmpty else { return }
        
        if password == passwordTextField.text { // 비밀번호 일치
            
            print("비밀번호 일치")
            
        } else { // 비밀번호 불일치
            
            print("print : 정규표현식 불일치, 비밀번호 불일치")
            
        }
        
    }
    
    @objc func emailTextFieldisValid(_ sender: UITextField) {
        
        guard let email = emailTextField.text, !email.isEmpty else { return }
        
        if loginModel.isValidEmail(email: email) {
            
            print("print : 이메일 정규표현식 일치")
            
        } else {
            
            print("print : 이메일 정규표현식 불일치")
        }
        
        
    }
    
    //MARK: Button Actions
     
    @IBAction func idOverlapButonClicked(_ sender: Any) {
        
        let id = idTextField.text ?? ""
        
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.checkLoginId(id: id))
            .responseJSON { response in
                print(response)
            }
        
    }
    @IBAction func emailOverlapButtonClicked(_ sender: Any) {
        
        let email = emailTextField.text ?? ""
        
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.checkEmail(email: email))
            .responseJSON { response in
                
            }
        
    }
    
    
    //MARK: Design Funtions

}
