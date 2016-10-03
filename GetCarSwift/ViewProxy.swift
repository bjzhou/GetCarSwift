//
//  ViewProxy.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

@objc protocol ViewProxy {
    func showToast(_ toast: String)
    func showViewController(_ vc: UIViewController)
}

extension ViewProxy {
    func setRootViewController() {
        UIApplication.shared.keyWindow?.rootViewController = R.storyboard.main.instantiateInitialViewController()
    }
}

extension UIViewController: ViewProxy {

    func showToast(_ toast: String) {
        Toast.makeToast(message: toast)
    }

    func showViewController(_ vc: UIViewController) {
        self.show(vc, sender: self)
    }

}
