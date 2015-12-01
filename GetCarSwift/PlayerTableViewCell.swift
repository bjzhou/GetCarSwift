//
//  PlayerTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/30.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.bounds = CGRectMake(0, 0, 44, 44)
    }

}
