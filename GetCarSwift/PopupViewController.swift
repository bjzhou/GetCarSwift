//
//  PopupView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

public class PopupViewController: UIViewController {
    var rootViewController: UIViewController?

    var cancelable = true

    init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
        self.modalPresentationStyle = .OverCurrentContext
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setTouchCancelable(cancelable: Bool) {
        self.cancelable = cancelable
    }

    override public func viewDidLoad() {
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        if let rootViewController = rootViewController {
            rootViewController.view.layer.cornerRadius = 5
            rootViewController.view.layer.shadowOpacity = 0.8
            rootViewController.view.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            self.view.addSubview(rootViewController.view)
            rootViewController.view.center = self.view.center
            self.addChildViewController(rootViewController)
            rootViewController.didMoveToParentViewController(self)
        }

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        if cancelable {
            dismissPopupViewController()
        }
    }

    public override func viewWillAppear(animated: Bool) {
        if let rootViewController = rootViewController {
            rootViewController.view.alpha = 0
            rootViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
            UIView.animateWithDuration(0.3, animations: {
                rootViewController.view.alpha = 1
                rootViewController.view.transform = CGAffineTransformMakeScale(1, 1)
            })
        }
    }

    public func setPopupViewFrame(frame: CGRect) {
        rootViewController?.view.frame = frame
        rootViewController?.view.center = self.view.center
    }

    public override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        if let rootViewController = rootViewController where flag {
            rootViewController.view.alpha = 1
            rootViewController.view.transform = CGAffineTransformMakeScale(1, 1)
            UIView.animateWithDuration(0.3, animations: {
                rootViewController.view.alpha = 0
                rootViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
                }) { _ in
                    super.dismissViewControllerAnimated(flag, completion: completion)
            }
        } else {
            super.dismissViewControllerAnimated(flag, completion: completion)
        }
    }
}

extension PopupViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view != self.view {
            return false
        }
        return true
    }
}