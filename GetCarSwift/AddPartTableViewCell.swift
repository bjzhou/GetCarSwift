//
//  AddPartTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class AddPartTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!

    var addDisposable: Disposable?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
