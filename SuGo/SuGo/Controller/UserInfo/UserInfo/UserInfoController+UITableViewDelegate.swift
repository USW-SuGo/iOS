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
    let postView = UIStoryboard(name: "PostView", bundle: nil)
    guard let postController = postView.instantiateViewController(withIdentifier: "postVC")
            as? PostController
    else { return }
    switch tableView.tag {
    case 1:
      postController.productPostId = userPost[indexPath.row].productIndex
      self.navigationController?.pushViewController(postController, animated: true)
    case 2:
      postController.productPostId = userSoldOutPost[indexPath.row].productIndex
      self.navigationController?.pushViewController(postController, animated: true)
    default: return
    }
    
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    switch tableView.tag {
    case 1:
      let lastIndex = userPost.count - 2
      guard let userId = userId,
              indexPath.row == lastIndex,
              !postLastPage else { return }
      postPage += 1
      getUserPost(userId: userId, page: postPage, size: 10)
    case 2:
      let lastIndex = userSoldOutPost.count - 2
      guard let userId = userId,
            indexPath.row == lastIndex,
            !soldOutPostLastPage else { return }
      soldOutPostPage += 1
      getUserSoldOutPost(userId: userId, page: soldOutPostPage, size: 10)
    default: return
    }
  }
  
}
