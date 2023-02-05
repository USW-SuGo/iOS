//
//  MyInfoController+UITableViewDataSource.swift
//  SuGo
//
//  Created by 한지석 on 2022/12/21.
//

import Foundation
import UIKit

extension MyInfoController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tableView.tag {
    case 1:
      return userPosting.count
    case 2:
      return userLikePosting.count
    case 3:
      return 1
    case 4:
      return 1
    default:
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView.tag {
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: "myPostingCell",
                                               for: indexPath) as! MyPostingCell
      if userPosting.count > 0 { // indexPath out of range 방지 위함.
        if let url = URL(string: userPosting[indexPath.row].imageLink) {
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
        cell.titleLabel.text = userPosting[indexPath.row].title
        cell.nicknameLabel.text = "내가 쓴 글"
        cell.placeUpdateCategoryLabel.text = "\(userPosting[indexPath.row].contactPlace) | \(userPosting[indexPath.row].updatedAt) | \(userPosting[indexPath.row].category)"
        cell.priceLabel.text = userPosting[indexPath.row].decimalWon
        cell.kebabMenuButton.tag = indexPath.row
        cell.kebabMenuButton.addTarget(self,
                                       action: #selector(kebabMenuClicked),
                                       for: .touchUpInside)
        cell.modifyButton.tag = indexPath.row
        cell.modifyButton.addTarget(self,
                                    action: #selector(modifyButtonClicked),
                                    for: .touchUpInside)
        cell.upPostButton.tag = indexPath.row
        cell.upPostButton.addTarget(self,
                                    action: #selector(upPostButtonClicked),
                                    for: .touchUpInside)
        cell.selectionStyle = .none
      }
      return cell
    case 2:
      let cell = tableView.dequeueReusableCell(withIdentifier: "userPostingCell",
                                                      for: indexPath) as! UserPostingCell
      if userLikePosting.count > 0 {
        if let url = URL(string: userLikePosting[indexPath.row].imageLink) {
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
        cell.placeUpdateCategoryLabel.text = "\(userLikePosting[indexPath.row].contactPlace) | \(userLikePosting[indexPath.row].updatedAt) | \(userLikePosting[indexPath.row].category)"
        cell.titleLabel.text = userLikePosting[indexPath.row].title
        cell.priceLabel.text = userLikePosting[indexPath.row].decimalWon
        cell.selectionStyle = .none
      }
      return cell
    case 3:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "emptyPostingCell",
                                                     for: indexPath) as? EmptyPostingCell else
      { return UITableViewCell() }
      cell.titleLabel.text = "아직 작성한 게시글이 없습니다."
      cell.explanationLabel.text = "거래하고 싶은 물품들을 수고에 올려보세요!"
      cell.selectionStyle = .none
      return cell
    case 4:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "emptyPostingCell",
                                                     for: indexPath) as? EmptyPostingCell else
      { return UITableViewCell() }
      cell.titleLabel.text = "아직 좋아요 누른 글이 없습니다."
      cell.explanationLabel.text = "관심가는 상품에 좋아요를 눌러보세요!"
      cell.selectionStyle = .none
      return cell
    default:
      return UITableViewCell()
    }
  }
}
