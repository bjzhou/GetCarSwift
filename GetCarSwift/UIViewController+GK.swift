//
//  UIViewController+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/27.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UIViewController {
    func dismissPopupViewController(animated: Bool = false, completion: (() -> Void)? = nil) {
        if let parent = self.parent, parent.isKind(of: PopupViewController.self) {
            parent.dismiss(animated: animated, completion: completion)
        } else if self.isKind(of: PopupViewController.self) {
            self.dismiss(animated: animated, completion: completion)
        }
    }

    func addEndEditingGesture(_ view: UIView) {
        let gestureRecgnizer = UITapGestureRecognizer()
        gestureRecgnizer.numberOfTapsRequired = 1
        _ = gestureRecgnizer.rx_event.takeUntil(self.rx_deallocated).subscribeNext { (gr) -> Void in
            self.view.endEditing(true)
        }
        view.addGestureRecognizer(gestureRecgnizer)
    }
}
