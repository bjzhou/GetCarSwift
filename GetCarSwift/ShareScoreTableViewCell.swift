//
//  ShareScoreTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class ShareScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var scoreTitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    var addDisposable: Disposable?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
