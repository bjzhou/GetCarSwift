//
//  PlayerTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/30.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    var medalImageView: UIImageView

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        medalImageView = UIImageView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.addSubview(medalImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        medalImageView.frame = CGRect(x: self.frame.width - 51, y: (self.frame.height - 35) / 2, width: 35, height: 35)
    }

}
