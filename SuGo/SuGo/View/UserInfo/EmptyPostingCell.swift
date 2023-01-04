//
//  EmptyPostingCell.swift
//  SuGo
//
//  Created by 한지석 on 2022/12/19.
//

import UIKit

class EmptyPostingCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var explanationLabel: UILabel!
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
    }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
    
}
