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
  let departments = UserDepartments().departments
  let collation = UILocalizedIndexedCollation.current()
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
              .response { response in
        
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
    // sections[section]
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
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return stride(from: 0, to: sections.count, by: 1).map { sections[$0] }
  }
  
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return index
  }
//  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//    let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
//    let sectionTitles = currentCollation.sectionTitles as NSArray
//    return sectionTitles.object(at: section) as? String
//  }
//
//  func sectionIndexTitlesForTableView(tableView: UITableView!) -> NSArray! {
//    let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
//    return currentCollation.sectionIndexTitles as NSArray
//  }
//
//  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//    let currentCollation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
//    return currentCollation.section(forSectionIndexTitle: index)
//  }
//
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
