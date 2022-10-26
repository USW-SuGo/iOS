//
//  DepartmentController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/25.
//

import UIKit

class DepartmentController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    
    let departments = ["국어국문학", "사학", "영어영문학", "러시아어"]
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}

extension DepartmentController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCell",
                                                 for: indexPath) as! DepartmentCell
        
        return cell
    }
    
    
}

class DepartmentCell: UITableViewCell {
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    override func layoutSubviews() {
        contentView.layer.borderColor = UIColor.systemGray2.cgColor
        contentView.layer.borderWidth = 0.2
        
    }
}
