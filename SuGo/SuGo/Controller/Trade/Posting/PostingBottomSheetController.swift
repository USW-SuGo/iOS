//
//  PostingBottomSheetController.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/04.
//

import UIKit

class PostingBottomSheetController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let categorySelect = CategorySelect.shared
    let category = ["서적", "전자기기", "생활용품", "기타"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("postBottomDismiss"), object: nil)
    }
    
}

extension PostingBottomSheetController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postingBottomCell", for: indexPath) as! PostingBottomSheetCell
        
        cell.categoryLabel.text = category[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categorySelect.postCategory = category[indexPath.row]
        self.dismiss(animated: true)
    }
    
}

class PostingBottomSheetCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
