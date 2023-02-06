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
      return userSalePosting.count
    case 2:
      return userSoldOutPosting.count
    default: return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView.tag {
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "userPostingCell",
                                                      for: indexPath) as! UserPostingCell
      if userSalePosting.count > 0 {
        if let url = URL(string: userSalePosting[indexPath.row].imageLink) {
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
        "\(userSalePosting[indexPath.row].contactPlace) | \(userSalePosting[indexPath.row].updatedAt) | \(userSalePosting[indexPath.row].category)"
        cell.titleLabel.text = userSalePosting[indexPath.row].title
        cell.priceLabel.text = userSalePosting[indexPath.row].price
        cell.selectionStyle = .none
      }
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(withIdentifier: "userPostingCell",
                                                      for: indexPath) as! UserPostingCell
      if userSoldOutPosting.count > 0 {
        if let url = URL(string: userSoldOutPosting[indexPath.row].imageLink) {
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
        "\(userSoldOutPosting[indexPath.row].contactPlace) | \(userSoldOutPosting[indexPath.row].updatedAt) | \(userSoldOutPosting[indexPath.row].category)"
        cell.titleLabel.text = userSoldOutPosting[indexPath.row].title
        cell.priceLabel.text = userSoldOutPosting[indexPath.row].price
        cell.selectionStyle = .none
      }
      return cell
    default:
      return UITableViewCell()
    }
    
  }
}
