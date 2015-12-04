//
//  TrackingViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/9.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackingViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
    }

}
