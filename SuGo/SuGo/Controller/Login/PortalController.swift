//
//  PortalController.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/12.
//

import UIKit
import WebKit

class PortalController: UIViewController {
  
  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let url = URL(string: "https://portal.suwon.ac.kr/enview/") else { return }
    let request = URLRequest(url: url)
    webView.load(request)
  }

}

extension PortalController: WKUIDelegate {
  override func loadView() {
    super.loadView()
    webView = WKWebView(frame: self.view.frame)
    webView.uiDelegate = self
    view = webView
  }
  
  //alert 처리
  func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
               initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
      let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
      self.present(alertController, animated: true, completion: nil) }

  //confirm 처리
  func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
      let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in completionHandler(false) }))
      alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler(true) }))
      self.present(alertController, animated: true, completion: nil) }
  
  // href="_blank" 처리
  func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
      if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
      return nil }
}
