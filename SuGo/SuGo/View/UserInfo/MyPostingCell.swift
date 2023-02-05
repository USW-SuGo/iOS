//
//  UserPostingCell.swift
//  SuGo
//
//  Created by 한지석 on 2022/11/08.
//

import UIKit

class MyPostingCell: UITableViewCell {

  @IBOutlet weak var productImage: UIImageView!
  @IBOutlet weak var placeUpdateCategoryLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var nicknameLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var upPostButton: UIButton!
  @IBOutlet weak var modifyButton: UIButton!
  @IBOutlet weak var kebabMenuButton: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        designButtons()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func designButtons() {
        upPostButton.layer.borderWidth = 0.5
        upPostButton.layer.borderColor = UIColor.systemGray5.cgColor
        
        modifyButton.layer.borderWidth = 0.5
        modifyButton.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
}
