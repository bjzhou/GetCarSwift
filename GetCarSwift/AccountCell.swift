//
//  AccountCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        accessoryView = UIImageView(image: UIImage(named: IMAGE_ARROW))
    }

}
