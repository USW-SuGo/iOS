//
//  SettingController.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/06.
//

import UIKit

import KeychainSwift

class SettingController: UIViewController {
  
  //MARK: IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  
  let settingModel = SettingModel()
  
  //MARK: Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    customBackButton()
      // Do any additional setup after loading the view.
  }
  
  private func customBackButton() {
    let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    backButtonItem.tintColor = .darkGray
    self.navigationItem.backBarButtonItem = backButtonItem
  }
  
  private func customAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { UIAlertAction in
      KeychainSwift().clear()
      self.navigationController?.popViewController(animated: true)
      if let tabBarController = self.tabBarController {
        tabBarController.selectedIndex = 0
      }
    }))
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    self.present(alert, animated: true, completion: nil)
  }
  
}

extension SettingController: UITableViewDelegate {
  
  // 비밀번호 변경 = section, row -> [1, 1]
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath{
    case [1, 0]: // 비밀번호 변경
      let changePasswordView = UIStoryboard(name: "ChangePasswordView", bundle: nil)
      guard let changePasswordController =
              changePasswordView.instantiateViewController(withIdentifier: "changePasswordVC")
              as? ChangePasswordController
      else { return }
      self.navigationController?.pushViewController(changePasswordController, animated: true)
    case [1, 2]: // 로그아웃
      customAlert(title: "로그아웃 하시겠어요?", message: "로그아웃을 하시려면 확인 버튼을 눌러주세요!")
      
    default:
      return
    }
  }
  
}

// menuCategories, loginMenus

extension SettingController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return settingModel.menuCategories.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingModel.loginMenus[section].count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return settingModel.menuCategories[section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell",
                                                   for: indexPath) as? SettingCell
    else { return UITableViewCell() }
    cell.testLabel.text = settingModel.loginMenus[indexPath.section][indexPath.row]
    return cell
  }
  
}

class SettingCell: UITableViewCell {
  
  @IBOutlet weak var testLabel: UILabel!
  
}
