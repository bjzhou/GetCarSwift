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
    @IBOutlet weak var messageDialog: UIView!
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var msgButton: UIButton!

    let buttonTitles = ["直线加速", "全球赛事"]

    override func viewDidLoad() {
        super.viewDidLoad()

        swiftPagesView.initializeWithVCsArrayAndButtonTitlesArray([R.storyboard.gkbox.data!, R.storyboard.gkbox.map!], buttonTitlesArray: buttonTitles, sender: self)

        self.navigationController?.view.addTapGesture { _ in
            if self.messageDialog.isHidden == false {
                self.messageDialog.isHidden = true
            }
        }

        _ = msgButton.rx_tap.takeUntil(msgButton.rx_deallocated).subscribeNext {
            let vc = ConversationListViewController()
            vc.hidesBottomBarWhenPushed = true
            self.showViewController(vc)
        }

        _ = friendButton.rx_tap.takeUntil(friendButton.rx_deallocated).subscribeNext {
            let vc = R.storyboard.friend.friend_list
            self.showViewController(vc!)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        showDisclaimerIfNeeded()
        messageDialog.isHidden = true
    }

    @IBAction func showMessageDialog(_ sender: AnyObject) {
        if messageDialog.isHidden == true {
            swiftPagesView.bringSubview(toFront: messageDialog)
            messageDialog.isHidden = false
        } else {
            self.messageDialog.isHidden = true
        }
    }

    func showDisclaimerIfNeeded() {
        let disclaimer = UserDefaults.standard.bool(forKey: "isDisclaimerShowed")
        if !disclaimer {
            let attributedMessage = AttributedString.loadHTMLString("<font size=4>1.使用本应用程序请按照道路交通管理条例安全驾驶，不超速、不逼车、不跨线、拒绝飙车！<br/><br/>2.使用本程序时，视为同意自行承担一切风险，本程序开发者以及公司对于使用本程序时所发生的任何直接或者间接的损失，一概免责。<br/><br/>3.在您使用本应用程序时，将视作您了解并同意本应用程序不能保证GPS位置等所有咨询数据的完全正确性。</font>")
            let alertController = UIAlertController(title: "使用条款以及免责声明", message: "", preferredStyle: .alert)
            alertController.setValue(attributedMessage, forKey: "attributedMessage")
            alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: {_ in
                UserDefaults.standard.set(true, forKey: "isDisclaimerShowed")
            }))
            present(alertController, animated: true, completion: nil)
        }
    }

}
