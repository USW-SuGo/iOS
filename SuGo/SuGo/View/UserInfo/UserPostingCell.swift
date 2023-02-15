//
//  LikePostingCell.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/08.
//

import UIKit

class UserPostingCell: UITableViewCell {

  @IBOutlet weak var productImage: UIImageView!
  @IBOutlet weak var placeUpdateCategoryLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
