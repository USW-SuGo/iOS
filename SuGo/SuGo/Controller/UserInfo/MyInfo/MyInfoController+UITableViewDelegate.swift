//
//  MyInfoController+UITableViewDelegate.swift
//  SuGo
//
//  Created by 한지석 on 2022/12/21.
//

import Foundation
import UIKit

import Alamofire
import SwiftyJSON

extension MyInfoController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch tableView.tag {
    case 1:
      return 178
    case 2:
      return 138
    case 3:
      return 138
    case 4, 5 ,6:
      return view.frame.maxY - seperateLine.frame.maxY - 100
//      return seperateLine.frame.minY - view.frame.minY
    default:
      return UITableView.automaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let postView = UIStoryboard(name: "PostView", bundle: nil)
    guard let postController = postView.instantiateViewController(withIdentifier: "postVC")
            as? PostController else { return }
    
    switch tableView.tag {
    case 1:
      postController.productPostId = myPost[indexPath.row].productIndex
    case 2:
      postController.productPostId = mySoldOutPost[indexPath.row].productIndex
    case 3:
      postController.productPostId = likePost[indexPath.row].productIndex
    default:
      return
    }
    
    navigationController?.pushViewController(postController, animated: true)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    switch tableView.tag {
    case 1:
      let lastIndex = myPost.count - 2
      guard lastIndex == indexPath.row else { return }
      myPostPage += 1
      guard !myPostLastPage else { return }
      getPost(api: PostRouter.getMyPost(page: myPostPage, size: 10),
              updatePost: updateMyPost)
    case 2:
      let lastIndex = mySoldOutPost.count - 2
      guard lastIndex == indexPath.row else { return }
      mySoldOutPage += 1
      guard !mySoldOutLastPage else { return }
      getPost(api: PostRouter.getMySoldOutPost(page: mySoldOutPage, size: 10),
              updatePost: updateMySoldOutPost)
    case 3:
      let lastIndex = likePost.count - 2
      guard lastIndex == indexPath.row else { return }
      likePostPage += 1
      guard !likePostLastPage else { return }
      getPost(api: LikePostRouter.getLikePost(page: likePostPage, size: 10),
              updatePost: updateLikePost)
    default:
      return
    }
    
  }
  
}
