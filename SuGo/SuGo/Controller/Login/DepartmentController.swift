//
//  DepartmentController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/25.
//

import UIKit

import Alamofire
import SwiftyJSON

class DepartmentController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showDepartmentLabel: UILabel!
    
    
    //MARK: Properties
    
    let departments = ["국어국문학", "사학", "영어영문학", "러시아어문학", "일어일문학", "중어중문학", "법학", "행정학", "소방행정학과(야)", "경제금융학과", "국제개발협력학과", "경영학과", "회계학과", "호텔경영학과", "외식경영학과", "바이오공학 및 마케팅", "융합화학산업", "건설환경공학", "환경에너지공학", "건축학과", "도시부동산학과", "산업공학과", "기계공학과", "전자재료공학", "전기공학과", "전자공학과", "신소재공학과", "화학공학과", "컴퓨터SW학과", "미디어SW학과", "정보통신공학과", "정보보호학과", "간호학과", "아동가족복지학과", "의류학과", "식품영양학과", "체육학과", "레저스포츠학과", "운동건강관리학과", "회화과", "조소과", "커뮤니케이션디자인학과", "패션디자인학과", "공예디자인학과", "작곡과", "성악과", "피아노과", "관현악과", "국악과", "영화영상과", "연극과", "문화컨텐츠테크놀러지학과", "클라우드융복합학과", "시스템반도체융복합학과"]
    
    let userInfo = UserInfo.shared
    var searchDepartments: [String] = []
    let searchController = UISearchController(searchResultsController: nil)
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    var searchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    //MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchController()
        // Do any additional setup after loading the view.
    }
    
    private func setUpSearchController() {
        tableView.separatorStyle = .none
        
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "학과를 검색하세요."
        // 사용자 검색 값에 따라 컨텐츠를 업데이트 시켜주는 프로퍼티
        searchController.searchResultsUpdater = self
        // 검색 시 기본 컨텐츠가 가려지는 여부
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.sizeToFit()
    }
    
    //MARK: Button Actions
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
      
        if userInfo.department != nil {
            
            let id = userInfo.loginId ?? ""
            let email = userInfo.email ?? ""
            let password = userInfo.password ?? ""
            let department = userInfo.department ?? ""
            
            AlamofireManager
                .shared
                .session
                .request(LoginRouter.join(loginId: id, email: email, password: password, department: department))
                .responseJSON { response in
          
                  guard let statusCode = response.response?.statusCode, statusCode == 200 else {
                    self.customAlert(title: "이미 인증메일이 발송되었습니다.",
                                     message: "중복된 아이디거나, 이미 인증메일이 발송되었습니다. 문제 발생시 문의 바랍니다.")
                    return }
                  
                  let emailAuthView = UIStoryboard(name: "EmailAuthView", bundle: nil)
                  guard let emailAuthController = emailAuthView.instantiateViewController(withIdentifier: "emailAuthVC") as? EmailAuthController else { return }
                  self.navigationController?.pushViewController(emailAuthController, animated: true)
                  
            }
        } else {
            
            customAlert(title: "학과를 선택해주세요 !", message: "본인 학과를 선택해주세요 !")
            
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    //MARK: Design Functions
    
    private func customAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

extension DepartmentController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMode ? searchDepartments.count : departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCell",
                                                 for: indexPath) as! DepartmentCell
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = searchMode ? searchDepartments[indexPath.row] : departments[indexPath.row]
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        userInfo.department = departments[indexPath.row]
        showDepartmentLabel.text = "\(userInfo.loginId ?? "")님의 학과는 \(userInfo.department ?? "") 입니다 !"
        print(userInfo.department)
        
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}

extension DepartmentController: UISearchResultsUpdating {
    
    func filteredContentForSearchText(_ searchText: String) {
        
        searchDepartments = departments.filter({ (department) -> Bool in
            return department.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    
}

class DepartmentCell: UITableViewCell {
    
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var checkButton: UIImageView!
    
    override func layoutSubviews() {
        contentView.layer.borderColor = UIColor.systemGray2.cgColor
        contentView.layer.borderWidth = 0.2
        
    }
    
    // cell selected 시 호출
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            checkButton.image = UIImage(systemName: "checkmark.circle")
        } else {
            checkButton.image = UIImage(systemName: "circle")
        }
    }
}
