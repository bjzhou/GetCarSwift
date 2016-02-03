//
//  FriendTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/4.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var sexImageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!

    var id = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        _ = followButton.rx_tap.takeUntil(self.rx_deallocated).subscribeNext {
            if self.followButton.selected {
                return
            }
            Toast.makeToastActivity()
            _ = User.addFriend(self.id).doOn { event in
                Toast.hideToastActivity()
                }.subscribeNext { res in
                    if res.code == 0 {
                        self.followButton.selected = true
                    }
            }
        }
    }

}
