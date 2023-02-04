//
//  MyInfoController+UITableViewDelegate.swift
//  SuGo
//
//  Created by 한지석 on 2022/12/21.
//

import Foundation
import UIKit

extension MyInfoController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch tableView.tag {
    case 1:
      return 178
    case 2:
      return 138
    case 3:
      return 370
    case 4:
      return 370
    default:
      return UITableView.automaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if tableView.tag == 1 {
      let lastIndex = userPosting.count - 2
      if indexPath.row == lastIndex {
        userPostingPage += 1
        if !userPostingLastPage {
          print("infinite scroll work")
          getMyPage(page: userPostingPage, size: 10, posting: "myPostings")
        }
      }
    } else if tableView.tag == 2 {
      let lastIndex = userLikePosting.count - 2
      if indexPath.row == lastIndex {
//        userLikePostingPage += 1
//        if !userLikePostingLastPage {
//          getMyPage(page: userLikePostingPage, size: 10, posting: "likePosting") }
        }
      }
    }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView.tag == 1 {
      let postView = UIStoryboard(name: "PostView", bundle: nil)
      guard let postController = postView.instantiateViewController(withIdentifier: "postVC")
              as? PostController else { return }
      postController.productPostId = userPosting[indexPath.row].productIndex
      navigationController?.pushViewController(postController, animated: true)
    } else if tableView.tag == 2 {
      let postView = UIStoryboard(name: "PostView", bundle: nil)
      guard let postController = postView.instantiateViewController(withIdentifier: "postVC")
              as? PostController else { return }
      postController.productPostId = userLikePosting[indexPath.row].productIndex
      navigationController?.pushViewController(postController, animated: true)
    }
  }
  
}
