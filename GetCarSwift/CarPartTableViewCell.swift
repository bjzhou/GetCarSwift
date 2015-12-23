//
//  CarPartTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class CarPartTableViewCell: UITableViewCell {

    @IBOutlet weak var partImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var delButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
