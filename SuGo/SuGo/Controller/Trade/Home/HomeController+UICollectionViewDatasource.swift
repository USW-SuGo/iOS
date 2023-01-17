//
//  HomeController+UICollectionViewDatasource.swift
//  SuGo
//
//  Created by 한지석 on 2023/01/18.
//

import UIKit

import Kingfisher

extension HomeController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell",
                                                  for: indexPath) as! HomeCollectionViewCell
    if homeProductContents.count > 0 {
      if let url = URL(string: homeProductContents[indexPath.row].imageLink[0]) {
//        let processor = DownsamplingImageProcessor(size: CGSize(width: cell.image.frame.width,
//                                                                  height: cell.image.frame.width * 1.33))
        cell.image.kf.indicatorType = .activity
        cell.image.kf.setImage(with: url,
                               placeholder: nil,
                               options: [
                                .transition(.fade(0.1))
//                                .processor(processor),
//                                .cacheMemoryOnly
                                    ],
                               progressBlock: nil)
        
        }
      cell.image.contentMode = .scaleAspectFill
      cell.backgroundColor = .white
      cell.placeUpdateCategoryLabel.text =
      "\(homeProductContents[indexPath.row].contactPlace) | \(homeProductContents[indexPath.row].updatedAt) | \(homeProductContents[indexPath.row].category)"
      cell.nicknameLabel.text = "\(homeProductContents[indexPath.row].nickname)"
      cell.priceLabel.text = "\(homeProductContents[indexPath.row].price)"
      cell.priceLabel.textColor = colorLiteralGreen
      cell.titleLabel.text = "\(homeProductContents[indexPath.row].title)"
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return homeProductContents.count
  }
  
}
