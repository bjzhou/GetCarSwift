//
//  ModStoreViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/9.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class ModStoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onBMW3Action(sender: UIButton) {
        self.parentViewController?.showViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("modStoreDetail"), sender: self.parentViewController)
    }
}
