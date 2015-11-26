//
//  UITableView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/12.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UITableView {
    func scrollToBottom(animated: Bool) {
        let delta = self.contentSize.height - self.bounds.size.height
        if delta > 0 {
            if animated {
                UIView.animateWithDuration(0.3) {
                    self.contentOffset = CGPoint(x: 0, y: delta)
                }
            } else {
                self.contentOffset = CGPoint(x: 0, y: delta)
            }
        }
    }
}
