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
        
        idTextField.addTarget(self, action: #selector(idTextFieldisValid), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldisValid), for: .editingChanged)
        
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
    }
    
    //MARK: Button Actions
     
    
    //MARK: Design Funtions

}
