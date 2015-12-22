//
//  FriendProfileViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/22.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class FriendProfileViewController: UIViewController {

    var uid = ""
    var avatarUrl = ""
    var nickname = ""
    var sex = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = self.presentingViewController {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: "dismiss")
        }
    }

    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
