//
//  SideMenuController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/28.
//

import UIKit
import SideMenu

class SideMenuNavController: SideMenuNavigationController {

    var testSideMenu = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftSide = true
    }

}

class SideMenuController: UIViewController{
    
    override func viewDidLoad() {
    }
    
}
