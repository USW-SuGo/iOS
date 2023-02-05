//
//  UserInfoController+UITableViewDelegate.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/04.
//

import Foundation
import UIKit

extension UserInfoController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 138
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lastIndex = userSalePosting.count - 2
    guard let userId = userId,
            indexPath.row == lastIndex,
            !salePostingLastPage else { return }
    salePostingPage += 1
    getUserPage(userId: userId, page: salePostingPage, size: 10)
  }
}
