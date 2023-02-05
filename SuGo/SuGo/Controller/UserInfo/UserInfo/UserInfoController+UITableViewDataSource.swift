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
    return userSalePosting.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
  }
}
