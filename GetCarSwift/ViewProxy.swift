//
//  ViewProxy.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

@objc protocol ViewProxy {
    optional func showToast(toast: String)
    optional func showViewController(vc: UIViewController)
    optional func setRootViewController()
}

extension ViewProxy {
    func setRootViewController() {
        UIApplication.sharedApplication().keyWindow?.rootViewController = mainStoryboard.instantiateInitialViewController()
    }
}