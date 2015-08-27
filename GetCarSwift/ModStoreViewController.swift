//
//  ModStoreViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/9.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModStoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //"mod_store_bg"
    }

    @IBAction func onBMW3Action(sender: UIButton) {
//        self.parentViewController?.showViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("modStoreDetail"), sender: self.parentViewController)
        let webBrowser = WebViewController()
        webBrowser.hidesBottomBarWhenPushed = true
        webBrowser.loadURLString("http://wap.koudaitong.com/v2/showcase/homepage?kdt_id=10707707")
        self.parentViewController?.showViewController(webBrowser, sender: self.parentViewController)
    }
}
