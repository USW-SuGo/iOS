//
//  UserInfoController+UITableViewDelegate.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/04.
//

import Foundation
import UIKit

extension UserInfoController: UITableViewDelegate {
  // Swtich tableView.tag = 1(판매 중인 글 O), 2(판매 완료 글 O), 3(판매 중인 글 X), 4(판매 완료 글 X)
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 138
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch tableView.tag {
    case 1:
      let postView = UIStoryboard(name: "PostView", bundle: nil)
      guard let postController = postView.instantiateViewController(withIdentifier: "postVC")
              as? PostController
      else { return }
      postController.productPostId = userSalePosting[indexPath.row].productIndex
      self.navigationController?.pushViewController(postController, animated: true)
    default: return
    }
    
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if tableView.tag == 1 {
      let lastIndex = userSalePosting.count - 2
      guard let userId = userId,
              indexPath.row == lastIndex,
              !salePostingLastPage else { return }
      salePostingPage += 1
      getUserPage(userId: userId, page: salePostingPage, size: 10)
    }
  }
}
