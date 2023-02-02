//
//  HomeController+UICollectionViewDelegate.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/18.
//

import UIKit

import Alamofire
import SwiftyJSON


extension HomeController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let lastIndex = homeProductContents.count - 3
    if indexPath.row == lastIndex {
      page += 1
      if !lastPage {
        callGetMainPage()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      AlamofireManager
        .shared
        .session
        .request(PostRouter.getDetailPost(productIndex: homeProductContents[indexPath.row].productIndex))
        .validate()
        .response { response in
          // if users have token and refreshToken still alive
          print(JSON(response.data ?? ""))
        if response.response?.statusCode == 200 {
            let postViewStoryboard = UIStoryboard(name: "PostView", bundle: nil)
            let nextViewController =
            postViewStoryboard.instantiateViewController(withIdentifier: "postVC") as! PostController
            nextViewController.productPostId = self.homeProductContents[indexPath.row].productIndex
            self.navigationController?.pushViewController(nextViewController, animated: true)
        // else show loginPage
        } else {
            self.keychain.clear()
            self.presentViewController(storyboard: "LoginView",
                                       identifier: "loginVC",
                                       fullScreen: false)
        }
      }
    }
  
}
