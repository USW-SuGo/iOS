//
//  SideMenuController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/28.
//

import UIKit
import SideMenu

class SideMenuController: SideMenuNavigationController {

    var testSideMenu = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leftSide = true
        // Do any additional setup after loading the view.
    }

}

//extension SideMenuController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return testSideMenu.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "sideCell", for: indexPath)
//
//        return cell
//    }
//
//}
//
//class SideMenuCell: UITableViewCell {
//
//}
//

class testViewController: UIViewController{
    override func viewDidLoad() {
        
    }
}
