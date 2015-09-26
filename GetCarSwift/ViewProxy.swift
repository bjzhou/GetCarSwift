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
}

extension ViewProxy {
    func setRootViewController() {
        UIApplication.sharedApplication().keyWindow?.rootViewController = mainStoryboard.instantiateInitialViewController()
    }
}

extension UIViewController: ViewProxy {

    func showToast(toast: String) {
        self.view.makeToast(message: toast)
    }

    func showViewController(vc: UIViewController) {
        self.showViewController(vc, sender: self)
    }
    
}