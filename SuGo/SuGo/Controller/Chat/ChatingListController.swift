//
//  ChatingListController.swift
//  SuGo
//
//  Created by 한지석 on 2022/09/21.
//

import UIKit

import Alamofire
import SwiftyJSON

class ChatingListController: UIViewController {

  //MARK: IBOutlets
    
  @IBOutlet weak var tableView: UITableView!
  
  //MARK: Properties
  
  let chatList: [ChatList] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  //MARK: Functions
  
  // func getChatList()
    
  //MARK: Button Actions
  
  //MARK: Design Functions
   
}

extension ChatingListController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "chatingListCell", for: indexPath) as! ChatingListCell
    
    return cell
  }
}

class ChatingListCell: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}
  
  override func layoutSubviews() {
  }
}
