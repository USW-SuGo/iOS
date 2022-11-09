//
//  TabBarController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/14.
//

import UIKit

import Alamofire
import SwiftyJSON
import KeychainSwift

class TabBarController: UITabBarController {

    let keychain = KeychainSwift()
    var index = 0
    var tokenIsValidCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func tokenIsValid() -> Bool {
        
        if tokenIsValidCheck {
            return true
        } else {
            return false
        }
        
    }

}

extension TabBarController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "거래" {
            index = 0
        } else {
            index = 1
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // 세마포어, 동기 처리를 위함 --> 이후 자세히 공부 해야할 필요 있음.
        
        let semaphore = DispatchSemaphore(value: 0)
        
        if index == 1 {
            
            AlamofireManager
                .shared
                .session
                .request(PageRouter.myPage(page: 0, size: 10))
                .validate()
                .responseJSON { response in
                    
                    if response.response?.statusCode != 200 {
                        
                        self.keychain.clear()
                        let nextStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
                        let nextViewController = nextStoryboard.instantiateViewController(withIdentifier: "loginVC")
                        nextViewController.modalPresentationStyle = .fullScreen
                        self.present(nextViewController, animated: true)
                        
                    }
                }
            }
        
        return true
        
    }
}
