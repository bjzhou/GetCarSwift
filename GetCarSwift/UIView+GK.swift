//
//  UIView+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/4.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import Foundation

extension UIView {
    func addTapGesture(action: (UIGestureRecognizer) -> Void) {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 1
        recognizer.cancelsTouchesInView = false
        _ = recognizer.rx_event.takeUntil(self.rx_deallocated).subscribeNext(action)
        self.addGestureRecognizer(recognizer)
    }
}
