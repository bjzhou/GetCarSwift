//
//  UIImageView+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/22.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UIImageView {
    func updateAvatar(uid: String, url: String, nickname: String, sex: Int = 1, tappable: Bool = true, inVC: UIViewController?) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width * 0.2
        self.kf_setImageWithURL(NSURL(string: url)!, placeholderImage: sex == 1 ? R.image.avatar : R.image.avatar_female)
        if tappable {
            let tapRecgnizer = UITapGestureRecognizer()
            tapRecgnizer.numberOfTapsRequired = 1
            _ = tapRecgnizer.rx_event.takeUntil(self.rx_deallocated).subscribeNext { (gr) -> Void in
                let vc = R.storyboard.friend.friend_profile
                vc?.uid = uid
                vc?.avatarUrl = url
                vc?.nicknameText = nickname
                vc?.sex = sex
                if let nav = inVC?.navigationController {
                    nav.showViewController(vc!)
                } else {
                    let nav = UINavigationController(rootViewController: vc!)
                    inVC?.showViewController(nav)
                }
                }
            self.addGestureRecognizer(tapRecgnizer)
            self.userInteractionEnabled = true
        }
    }
}
