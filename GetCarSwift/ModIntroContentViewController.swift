//
//  ModIntroContentViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/7.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModIntroContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        messageTextView.contentOffset.y = 0
    }
}
