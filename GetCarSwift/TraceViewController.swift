//
//  TraceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TraceViewController: UIViewController {
    @IBOutlet weak var swiftPagesView: SwiftPages!

    var a:Double = 0

    let VCIDs = ["data", "map"];
    let buttonTitles = ["数据", "地图"];

    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles, sender: self)

        showDisclaimerIfNeeded()
    }

    func showDisclaimerIfNeeded() {
        let disclaimer = NSUserDefaults.standardUserDefaults().boolForKey("isDisclaimerShowed")
        if !disclaimer {
            let alertController = UIAlertController(title: "使用条款以及免责声明", message: "1.使用本应用程序请按照道路交通管理条例安全驾驶，不超速、不逼车、不跨线、拒绝飙车！\n2.使用本程序时，视为同意自行承担一切风险，本程序开发者以及公司对于使用本程序时所发生的任何直接或者间接的损失，一概免责。\n3.在您使用本应用程序时，将视作您了解并同意本应用程序不能保证GPS位置等所有咨询数据的完全正确性。", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {_ in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isDisclaimerShowed")
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
