//
//  PostViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/21.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var hiddenTagViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hiddenTagView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    @IBAction func onTagSelected(sender: UIButton) {
        for tag in 310...315 {
            let button = self.view.viewWithTag(tag) as? UIButton
            if sender.tag == tag {
                sender.selected = true
            } else {
                button?.selected = false
            }
        }
    }

    @IBAction func onTagExpand(sender: UIButton) {
        UIView.transitionWithView(hiddenTagView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.hiddenTagViewHeight.constant = sender.selected ? 0 : 102
            self.hiddenTagView.layoutIfNeeded()
            }, completion: {(arg) in
                sender.selected = !sender.selected
        })
    }
}
