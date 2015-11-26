//
//  UIViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/27.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UIViewController {
    func dismissPopupViewController() {
        if let parent = self.parentViewController where parent.isKindOfClass(PopupViewController) {
            parent.dismissViewControllerAnimated(false, completion: nil)
        } else if self.isKindOfClass(PopupViewController) {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
