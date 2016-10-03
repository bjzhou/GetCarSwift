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

        _ = followButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: {
            Toast.makeToastActivity()
            if self.followButton.isSelected {
                _ = User.removeFriend(self.id).do { _ in
                    Toast.hideToastActivity()
                    }.subscribe(onNext: { res in
                        if res.code == 0 {
                            self.followButton.isSelected = false
                        }
                })
            } else {
                _ = User.addFriend(self.id).do { _ in
                    Toast.hideToastActivity()
                    }.subscribe(onNext: { res in
                        if res.code == 0 {
                            self.followButton.isSelected = true
                        }
                })
            }
        })
    }

}
