//
//  UserInfoController+UITableViewDatasource.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/04.
//

import Foundation
import UIKit

extension UserInfoController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tableView.tag {
    case 1:
      return userSalePost.count
    case 2:
      return userSoldOutPost.count
    default: return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView.tag {
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "userPostingCell",
                                                      for: indexPath) as! UserPostingCell
      if userSalePost.count > 0 {
        if let url = URL(string: userSalePost[indexPath.row].imageLink) {
          cell.productImage.kf.indicatorType = .activity
          cell.productImage.kf.setImage(with: url,
                                        placeholder: nil,
                                        options: [
                                          .transition(.fade(0.1)),
                                          .cacheOriginalImage
                                        ],
                                        progressBlock: nil)
        }
        cell.productImage.contentMode = .scaleAspectFill
        cell.productImage.layer.cornerRadius = 6.0
        cell.placeUpdateCategoryLabel.text =
        "\(userSalePost[indexPath.row].contactPlace) | \(userSalePost[indexPath.row].updatedAt) | \(userSalePost[indexPath.row].category)"
        cell.titleLabel.text = userSalePost[indexPath.row].title
        cell.priceLabel.text = userSalePost[indexPath.row].price
        cell.selectionStyle = .none
      }
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(withIdentifier: "userPostingCell",
                                                      for: indexPath) as! UserPostingCell
      if userSoldOutPost.count > 0 {
        if let url = URL(string: userSoldOutPost[indexPath.row].imageLink) {
          cell.productImage.kf.indicatorType = .activity
          cell.productImage.kf.setImage(with: url,
                                        placeholder: nil,
                                        options: [
                                          .transition(.fade(0.1)),
                                          .cacheOriginalImage
                                        ],
                                        progressBlock: nil)
        }
        cell.productImage.contentMode = .scaleAspectFill
        cell.productImage.layer.cornerRadius = 6.0
        cell.placeUpdateCategoryLabel.text =
        "\(userSoldOutPost[indexPath.row].contactPlace) | \(userSoldOutPost[indexPath.row].updatedAt) | \(userSoldOutPost[indexPath.row].category)"
        cell.titleLabel.text = userSoldOutPost[indexPath.row].title
        cell.priceLabel.text = userSoldOutPost[indexPath.row].price
        cell.selectionStyle = .none
      }
      return cell
    default:
      return UITableViewCell()
    }
    
  }
}
