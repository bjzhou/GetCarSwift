//
//  PopupView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

public enum PopupType {
    case Alert
    case ActionSheet
}

public class PopupViewController: UIViewController {
    var rootViewController: UIViewController
    var popupType: PopupType
    var sender: AnyObject?

    var cancelable = true

    init(rootViewController: UIViewController, popupType: PopupType = .Alert, sender: AnyObject? = nil) {
        self.rootViewController = rootViewController
        self.popupType = popupType
        self.sender = sender
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setTouchCancelable(_ cancelable: Bool) {
        self.cancelable = cancelable
    }

    override public func viewDidLoad() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        rootViewController.view.layer.cornerRadius = 5
        rootViewController.view.layer.shadowOpacity = 0.8
        rootViewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)

        switch popupType {
        case .Alert:
            rootViewController.view.center = self.view.center
        case .ActionSheet:
            rootViewController.view.frame.origin = CGPoint(x: (self.view.frame.width - rootViewController.view.frame.width) / 2, y: self.view.frame.height - rootViewController.view.frame.height)
        }
        self.view.addSubview(rootViewController.view)
        self.addChildViewController(rootViewController)
        rootViewController.didMove(toParentViewController: self)

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        _ = tapRecognizer.rx.event.takeUntil(self.rx.deallocated).subscribe(onNext: { (gr) -> Void in
            if self.cancelable {
                self.dismissPopupViewController(animated: self.popupType == .ActionSheet)
            }
        })
        self.view.addGestureRecognizer(tapRecognizer)
    }

    public override func viewWillAppear(_ animated: Bool) {
        switch popupType {
        case .Alert:
            rootViewController.view.alpha = 0
            rootViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.3, animations: {
                self.rootViewController.view.alpha = 1
                self.rootViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        case .ActionSheet:
            rootViewController.view.transform = CGAffineTransform(translationX: 0, y: rootViewController.view.frame.height)
            UIView.animate(withDuration: 0.3, animations: {
                self.rootViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }

    }

    public func setPopupViewFrame(_ frame: CGRect) {
        rootViewController.view.frame = frame
        rootViewController.view.center = self.view.center
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if flag {
            switch popupType {
            case .Alert:
                rootViewController.view.alpha = 1
                rootViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                UIView.animate(withDuration: 0.3, animations: {
                    self.rootViewController.view.alpha = 0
                    self.rootViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }) { _ in
                        super.dismiss(animated: false, completion: completion)
                }
            case .ActionSheet:
                rootViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
                UIView.animate(withDuration: 0.3, animations: {
                    self.rootViewController.view.transform = CGAffineTransform(translationX: 0, y: self.rootViewController.view.frame.height)
                    }) { _ in
                        super.dismiss(animated: false, completion: completion)
                }
            }

        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

extension PopupViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.view {
            return false
        }
        return true
    }
}
