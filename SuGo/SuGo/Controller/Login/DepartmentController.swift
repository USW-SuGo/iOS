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
  @IBOutlet weak var nextButton: UIButton!
  
  //MARK: Properties
    
  let sections = ["ㄱ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅍ", "ㅎ"] // 12
  
  let departments = [["간호학과", "건설환경공학", "건축학과", "경영학과", "경제금융학과", "공예디자인학과", "관현악과", "국악과", "국어국문학", "국제개발협력학과", "기계공학과"],
                     ["도시부동산학과"],
                     ["러시아어문학", "레저스포츠학과"],
                     ["문화컨텐츠테크놀러지학과", "미디어SW학과"],
                     ["바이오공학 및 마케팅", "법학"],
                     ["사학", "산업공학과", "성악과", "소방행정학과(야)", "시스템반도체융복합학과", "식품영양학과", "신소재공학과"],
                     ["아동가족복지학과", "연극과", "영어영문학", "영화영상과", "외식경영학과", "운동건강관리학과", "융합화학산업", "의류학과", "일어일문학"],
                     ["작곡과", "전기공학과", "전자공학과", "전자재료공학", "정보보호학과", "정보통신공학과", "조소과", "중어중문학"],
                     ["체육학과"],
                     ["커뮤니케이션디자인학과", "컴퓨터SW학과", "클라우드융복합학과"],
                     ["패션디자인학과", "피아노과"],
                     ["행정학", "호텔경영학과", "화학공학과", "환경에너지공학", "회계학과", "회화과"]]
    
  let userInfo = UserInfo.shared
  var searchDepartments: [String] = []
  let searchController = UISearchController(searchResultsController: nil)
  let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
//  var searchMode: Bool {
//      return searchController.isActive && !searchController.searchBar.text!.isEmpty
//  }
  
  //MARK: Functions
  
  override func viewDidLoad() {
      super.viewDidLoad()
      designIBOutlets()
      // Do any additional setup after loading the view.
  }
  
//  private func setUpSearchController() {
//      tableView.separatorStyle = .none
//
//      tableView.tableHeaderView = searchController.searchBar
//
//      searchController.searchBar.placeholder = "학과를 검색하세요."
//      // 사용자 검색 값에 따라 컨텐츠를 업데이트 시켜주는 프로퍼티
//      searchController.searchResultsUpdater = self
//      // 검색 시 기본 컨텐츠가 가려지는 여부
//      searchController.obscuresBackgroundDuringPresentation = false
//
//      searchController.searchBar.searchBarStyle = .prominent
//      searchController.searchBar.showsCancelButton = false
//      searchController.searchBar.sizeToFit()
//  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
  }
  
  //MARK: Button Actions
  
  @IBAction func nextButtonClicked(_ sender: Any) {
    
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
                
                guard let responseData = response.data else { return }
                self.userInfo.userIndex = JSON(responseData)["id"].intValue
                
                let emailAuthView = UIStoryboard(name: "EmailAuthView", bundle: nil)
                guard let emailAuthController = emailAuthView.instantiateViewController(withIdentifier: "emailAuthVC") as? EmailAuthController else { return }
                emailAuthController.modalPresentationStyle = .fullScreen
                self.present(emailAuthController, animated: true)
                
          }
      } else {
          
          customAlert(title: "학과를 선택해주세요 !", message: "본인 학과를 선택해주세요 !")
          
      }
  }
  
  @IBAction func closeButtonClicked(_ sender: Any) {
      self.dismiss(animated: true)
  }
  
  //MARK: Design Functions
  
  private func designIBOutlets() {
    nextButton.layer.cornerRadius = 6.0
  }
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    self.present(alert, animated: true, completion: nil)
  }
  
}

extension DepartmentController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]
  }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section{
      case 0:
        return departments[0].count
      case 1:
        return departments[1].count
      case 2:
        return departments[2].count
      case 3:
        return departments[3].count
      case 4:
        return departments[4].count
      case 5:
        return departments[5].count
      case 6:
        return departments[6].count
      case 7:
        return departments[7].count
      case 8:
        return departments[8].count
      case 9:
        return departments[9].count
      case 10:
        return departments[10].count
      case 11:
        return departments[11].count
      default:
        return 0
      }
      // searchMode ? searchDepartments.count : departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCell",
                                                 for: indexPath) as! DepartmentCell
      switch indexPath.section{
      case 0:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[0][indexPath.row]
      case 1:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[1][indexPath.row]
      case 2:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[2][indexPath.row]
      case 3:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[3][indexPath.row]
      case 4:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[4][indexPath.row]
      case 5:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[5][indexPath.row]
      case 6:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[6][indexPath.row]
      case 7:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[7][indexPath.row]
      case 8:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[8][indexPath.row]
      case 9:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[9][indexPath.row]
      case 10:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[10][indexPath.row]
      case 11:
        cell.checkButton.image = UIImage(systemName: "circle")
        cell.departmentLabel.text = departments[11][indexPath.row]

      default:
        break
      }
      
        
      return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      userInfo.department = departments[indexPath.section][indexPath.row]
      showDepartmentLabel.text = "\(userInfo.loginId ?? "")님의 학과는 \(userInfo.department ?? "") 입니다 !"
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 60.0
    }
    
}

//extension DepartmentController: UISearchResultsUpdating {
//
//    func filteredContentForSearchText(_ searchText: String) {
//
//        searchDepartments = departments.filter({ (department) -> Bool in
//            return department.lowercased().contains(searchText.lowercased())
//        })
//
//        tableView.reloadData()
//    }
//
//    func updateSearchResults(for searchController: UISearchController) {
//        filteredContentForSearchText(searchController.searchBar.text ?? "")
//    }
//}

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
