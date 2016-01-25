//
//  GkboxViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class GkboxViewController: UIViewController {
    @IBOutlet weak var swiftPagesView: SwiftPages!
//    @IBOutlet weak var messageDialog: UIView!
//    @IBOutlet weak var friendButton: UIButton!
//    @IBOutlet weak var msgButton: UIButton!

    let buttonTitles = ["直线加速", "全球赛事"]

    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCsArrayAndButtonTitlesArray([R.storyboard.gkbox.data!, R.storyboard.gkbox.map!], buttonTitlesArray: buttonTitles, sender: self)

//        self.navigationController?.view.addTapGesture { _ in
//            if self.messageDialog.hidden == false {
//                self.messageDialog.hidden = true
//            }
//        }
//
//        _ = msgButton.rx_tap.takeUntil(msgButton.rx_deallocated).subscribeNext {
//            let vc = ConversationListViewController()
//            vc.hidesBottomBarWhenPushed = true
//            self.showViewController(vc)
//        }
//
//        _ = friendButton.rx_tap.takeUntil(friendButton.rx_deallocated).subscribeNext {
//            let vc = R.storyboard.friend.friend_list
//            self.showViewController(vc!)
//        }
    }

    override func viewWillAppear(animated: Bool) {
        showDisclaimerIfNeeded()
//        messageDialog.hidden = true
    }

//    @IBAction func showMessageDialog(sender: AnyObject) {
//        if messageDialog.hidden == true {
//            swiftPagesView.bringSubviewToFront(messageDialog)
//            messageDialog.hidden = false
//        } else {
//            self.messageDialog.hidden = true
//        }
//    }

    func showDisclaimerIfNeeded() {
        let disclaimer = NSUserDefaults.standardUserDefaults().boolForKey("isDisclaimerShowed")
        if !disclaimer {
            let attributedMessage = NSAttributedString.loadHTMLString("<font size=4>1.使用本应用程序请按照道路交通管理条例安全驾驶，不超速、不逼车、不跨线、拒绝飙车！<br/><br/>2.使用本程序时，视为同意自行承担一切风险，本程序开发者以及公司对于使用本程序时所发生的任何直接或者间接的损失，一概免责。<br/><br/>3.在您使用本应用程序时，将视作您了解并同意本应用程序不能保证GPS位置等所有咨询数据的完全正确性。</font>")
            let alertController = UIAlertController(title: "使用条款以及免责声明", message: "", preferredStyle: .Alert)
            alertController.setValue(attributedMessage, forKey: "attributedMessage")
            alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {_ in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isDisclaimerShowed")
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
