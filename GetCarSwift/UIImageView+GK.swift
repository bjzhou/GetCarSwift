//
//  UIImageView+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/22.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UIImageView {
    func updateAvatar(_ uid: String, url: String, tappable: Bool = true, inVC: UIViewController?) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width * 0.2
        self.kf_setImageWithURL(NSURL(string: url)! as URL, placeholderImage: R.image.avatar)
        if tappable {
            let tapRecgnizer = UITapGestureRecognizer()
            tapRecgnizer.numberOfTapsRequired = 1
            _ = tapRecgnizer.rx_event.takeUntil(self.rx_deallocated).subscribeNext { (gr) -> Void in
                let vc = R.storyboard.friend.friend_profile
                vc?.hidesBottomBarWhenPushed = true
                vc?.uid = uid
                if let nav = inVC?.navigationController {
                    nav.showViewController(vc!)
                } else {
                    let nav = UINavigationController(rootViewController: vc!)
                    inVC?.showViewController(nav)
                }
            }
            self.addGestureRecognizer(tapRecgnizer)
            self.isUserInteractionEnabled = true
        }
    }
}
