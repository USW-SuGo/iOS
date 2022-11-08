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
    
    //MARK: Properties
    
    let keychain = KeychainSwift()
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                print(JSON(response.data))
            }
    }
    
    //MARK: Button Actions
    
    //MARK: Design Functions
    

}
