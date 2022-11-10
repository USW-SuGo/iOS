//
//  EmailAuthController.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/10.
//

import UIKit

import Alamofire
import SwiftyJSON
import WebKit

class EmailAuthController: UIViewController {

  //MARK: IBOutlets
  
  @IBOutlet weak var emailAuthBox: UIView!
  @IBOutlet weak var emailAuthTextField: UITextField!
  @IBOutlet weak var portalButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  
  //MARK: Properties
  
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
  
  //MARK: Life Cycle
  
//  override func loadView() {
//    let webConfiguration = WKWebViewConfiguration()
//    webView = WKWebView(frame: .zero, configuration: webConfiguration)
//    webView.uiDelegate = self
//    view = webView
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    designIBOutlets()
    }
  
  //MARK: Functions
  
  //MARK: Button Actions
  
  @IBAction func portalButtonClicked(_ sender: Any) {
//    guard let url = URL(string: "https://naver.com") else { return }
//    let request = URLRequest(url: url)
//    webView.load(request)
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
    customAlert(title: "회원가입을 종료하시겠어요?", message: "종료하게 될 경우, 한 시간 뒤에 동일 계정으로 가입이 가능합니다.")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
  }
  
  //MARK: Design Functions
  
  private func designIBOutlets() {
    emailAuthBox.layer.cornerRadius = 3.0
    emailAuthBox.layer.borderWidth = 0.7
    emailAuthBox.layer.borderColor = UIColor.lightGray.cgColor
    
    signUpButton.layer.cornerRadius = 6.0
    
    portalButton.layer.cornerRadius = 6.0
    portalButton.layer.borderColor = colorLiteralGreen.cgColor
    portalButton.layer.borderWidth = 0.5
  }
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { UIAlertAction in
      self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }))
    alert.addAction(UIAlertAction(title: "취소", style: .destructive))
    self.present(alert, animated: true, completion: nil)
  }
    
}
