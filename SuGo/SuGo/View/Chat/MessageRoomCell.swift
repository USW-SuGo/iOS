//
//  MessageRoomCell.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/20.
//

import UIKit

class MessageRoomCell: UITableViewCell {

  @IBOutlet weak var messageLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  
  override func layoutSubviews() {
    paddingMessage()
  }
  
  func paddingMessage() {

  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
    
}
