//
//  ReceiveMessageCell.swift
//  SuGo
//
//  Created by 한지석 on 2023/02/21.
//

import UIKit

class ReceiveMessageCell: UITableViewCell {

  @IBOutlet weak var messageView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var messageTimeLabel: UILabel!
  
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
