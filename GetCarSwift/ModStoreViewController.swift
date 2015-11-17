//
//  ModStoreViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/9.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModStoreViewController: UIViewController {

    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var storeBg: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        storeButton.setAttributedTitle(NSAttributedString(string: "进入商城", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSForegroundColorAttributeName: UIColor.whiteColor()]), forState: .Normal)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTapStoreBg")
        tapRecognizer.numberOfTapsRequired = 1
        storeBg.addGestureRecognizer(tapRecognizer)
    }

    func didTapStoreBg() {
        let webBrowser = WebViewController()
        webBrowser.hidesBottomBarWhenPushed = true
        webBrowser.loadURLString("http://wap.koudaitong.com/v2/showcase/homepage?kdt_id=10707707")
        self.parentViewController?.showViewController(webBrowser, sender: self.parentViewController)
    }

    @IBAction func onBMW3Action(sender: UIButton) {
        didTapStoreBg()
    }
}
