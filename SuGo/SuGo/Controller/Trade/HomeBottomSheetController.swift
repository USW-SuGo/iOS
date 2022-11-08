//
//  BottomSheetController.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/03.
//

import UIKit

class HomeBottomSheetController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topLineView: UIView!
    
    let category = ["전체", "서적", "전자기기", "생활용품", "기타"]
    let categorySelect = CategorySelect.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topLineView.layer.cornerRadius = 6.0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("homeBottomDismiss"), object: nil)
    }


}

extension HomeBottomSheetController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bottomCell",
                                                      for: indexPath) as! HomeBottomSheetCell
        
        cell.categoryLabel.text = category[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categorySelect.homeCategory = category[indexPath.row]
        self.dismiss(animated: true)
//
//        let homeView = UIStoryboard(name: "HomeView", bundle: nil)
//        let homeViewController =
//        homeView.instantiateViewController(withIdentifier: "homeVC") as! HomeController
//        homeViewController.viewWillAppear(true)
    }
    
    
}

class HomeBottomSheetCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
