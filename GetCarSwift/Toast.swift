//
//  HRToast + UIView.swift
//  ToastDemo
//
//  Created by Rannie on 14/7/6.
//  Copyright (c) 2014年 Rannie. All rights reserved.
//

import UIKit

/*
*  Infix overload method
*/
func / (lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

/*
*  Toast Config
*/
let toastDefaultDuration  =   2.0
let toastFadeDuration     =   0.2
let toastHorizontalMargin: CGFloat  =   10.0
let toastVerticalMargin: CGFloat    =   10.0

let toastPositionBottom   =   "bottom"
let toastPositionTop      =   "top"
let toastPositionCenter   =   "center"

let toastPositionDefault = toastPositionCenter

// activity
let toastActivityWidth: CGFloat     = 100.0
let toastActivityHeight: CGFloat    = 100.0
let toastActivityPositionDefault    = "center"

// image size
let toastImageViewWidth: CGFloat    = 80.0
let toastImageViewHeight: CGFloat   = 80.0

// label setting
let toastMaxWidth: CGFloat          = 0.8      // 80% of parent view width
let toastMaxHeight: CGFloat         = 0.8
let toastFontSize: CGFloat          = 16.0
let toastMaxTitleLines              = 0
let toastMaxMessageLines            = 0

// shadow appearance
let toastShadowOpacity: CGFloat     = 0.8
let toastShadowRadius: CGFloat      = 6.0
let toastShadowOffset: CGSize       = CGSize(width: CGFloat(4.0), height: CGFloat(4.0))

let toastOpacity: CGFloat           = 0.8
let toastCornerRadius: CGFloat      = 10.0

var toastActivityView: UnsafePointer<UIView>    =   nil
var toastTimer: UnsafePointer<NSTimer>          =   nil
var toastView: UnsafePointer<UIView>            =   nil

/*
*  Custom Config
*/
let toastHidesOnTap       =   true
let toastDisplayShadow    =   true

//HRToast (UIView + Toast using Swift)

extension UIView {

    /*
    *  public methods
    */
    func makeToast(message msg: String) {
        self.makeToast(message: msg, duration: toastDefaultDuration, position: toastPositionDefault)
    }

    func makeToast(message msg: String, duration: Double, position: AnyObject) {
        let toast = self.viewForMessage(msg, title: nil, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }

    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String) {
        let toast = self.viewForMessage(msg, title: title, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }

    func makeToast(message msg: String, duration: Double, position: AnyObject, image: UIImage) {
        let toast = self.viewForMessage(msg, title: nil, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }

    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String, image: UIImage) {
        let toast = self.viewForMessage(msg, title: title, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }

    func showToast(toast: UIView) {
        self.showToast(toast: toast, duration: toastDefaultDuration, position: toastPositionDefault)
    }

    func showToast(toast toast: UIView, duration: Double, position: AnyObject) {
        if let existToast = objc_getAssociatedObject(self, &toastView) as? UIView {
            if let timer: NSTimer = objc_getAssociatedObject(existToast, &toastTimer) as? NSTimer {
                timer.invalidate()
            }
            self.hideToast(toast: existToast, force: false)
        }

        toast.center = self.centerPointForPosition(position, toast: toast)
        toast.alpha = 0.0

        if toastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: Selector("handleToastTapped:"))
            toast.addGestureRecognizer(tapRecognizer)
            toast.userInteractionEnabled = true
            toast.exclusiveTouch = true
        }

        self.addSubview(toast)
        objc_setAssociatedObject(self, &toastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)

        UIView.animateWithDuration(toastFadeDuration,
            delay: 0.0, options: [.CurveEaseOut, .AllowUserInteraction],
            animations: {
                toast.alpha = 1.0
            },
            completion: { (finished: Bool) in
                let timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("toastTimerDidFinish:"), userInfo: toast, repeats: false)
                objc_setAssociatedObject(toast, &toastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }

    func makeToastActivity() {
        self.makeToastActivity(position: toastActivityPositionDefault)
    }

    func makeToastActivityWithMessage(message msg: String) {
        self.makeToastActivity(position: toastActivityPositionDefault, message: msg)
    }

    func makeToastActivity(position pos: AnyObject, message msg: String = "") {
        let existingActivityView: UIView? = objc_getAssociatedObject(self, &toastActivityView) as? UIView
        if existingActivityView != nil { return }

        let activityView = UIView(frame: CGRect(x: 0, y: 0, width: toastActivityWidth, height: toastActivityHeight))
        activityView.center = self.centerPointForPosition(pos, toast: activityView)
        activityView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(toastOpacity)
        activityView.alpha = 0.0
        activityView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        activityView.layer.cornerRadius = toastCornerRadius

        if toastDisplayShadow {
            activityView.layer.shadowColor = UIColor.blackColor().CGColor
            activityView.layer.shadowOpacity = Float(toastShadowOpacity)
            activityView.layer.shadowRadius = toastShadowRadius
            activityView.layer.shadowOffset = toastShadowOffset
        }

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2, y: activityView.bounds.size.height / 2)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        if (!msg.isEmpty) {
            activityIndicatorView.frame.origin.y -= 10
            let activityMessageLabel = UILabel(frame: CGRect(x: activityView.bounds.origin.x, y: (activityIndicatorView.frame.origin.y + activityIndicatorView.frame.size.height + 10), width: activityView.bounds.size.width, height: 20))
            activityMessageLabel.textColor = UIColor.whiteColor()
            activityMessageLabel.font = (msg.characters.count<=10) ? UIFont(name:activityMessageLabel.font.fontName, size: 16) : UIFont(name:activityMessageLabel.font.fontName, size: 13)
            activityMessageLabel.textAlignment = .Center
            activityMessageLabel.text = msg
            activityView.addSubview(activityMessageLabel)
        }

        self.addSubview(activityView)

        // associate activity view with self
        objc_setAssociatedObject(self, &toastActivityView, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        UIView.animateWithDuration(toastFadeDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                activityView.alpha = 1.0
            },
            completion: nil)
    }

    func hideToastActivity() {
        if let existingActivityView = objc_getAssociatedObject(self, &toastActivityView) as? UIView {
            UIView.animateWithDuration(toastFadeDuration,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    existingActivityView.alpha = 0.0
                },
                completion: { (finished: Bool) in
                    existingActivityView.removeFromSuperview()
                    objc_setAssociatedObject(self, &toastActivityView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            })
        }
    }

    /*
    *  private methods (helper)
    */
    func hideToast(toast toast: UIView) {
        self.hideToast(toast: toast, force: false)
    }

    func hideToast(toast toast: UIView, force: Bool) {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &toastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        if force {
            completeClosure(true)
        } else {
            UIView.animateWithDuration(toastFadeDuration,
                delay: 0.0,
                options: [.CurveEaseIn, .BeginFromCurrentState],
                animations: {
                    toast.alpha = 0.0
                },
                completion:completeClosure)
        }
    }

    func toastTimerDidFinish(timer: NSTimer) {
        self.hideToast(toast: timer.userInfo as? UIView ?? UIView())
    }

    func handleToastTapped(recognizer: UITapGestureRecognizer) {
        let timer = objc_getAssociatedObject(self, &toastTimer) as? NSTimer
        timer?.invalidate()

        self.hideToast(toast: recognizer.view!)
    }

    func centerPointForPosition(position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let
            viewSize  = self.bounds.size
            if position.lowercaseString == toastPositionTop {
                return CGPoint(x: viewSize.width/2, y: toastSize.height/2 + toastVerticalMargin)
            } else if position.lowercaseString == toastPositionBottom {
                return CGPoint(x: viewSize.width/2, y: viewSize.height - toastSize.height/2 - toastVerticalMargin)
            } else if position.lowercaseString == toastPositionCenter {
                return CGPoint(x: viewSize.width/2, y: viewSize.height/2)
            }
        } else if position is NSValue {
            return position.CGPointValue
        }

        print("Warning: Invalid position for toast.")
        return self.centerPointForPosition(toastPositionDefault, toast: toast)
    }

    func viewForMessage(msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil { return nil }

        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?

        let wrapperView = UIView()
        wrapperView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        wrapperView.layer.cornerRadius = toastCornerRadius
        wrapperView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(toastOpacity)

        if toastDisplayShadow {
            wrapperView.layer.shadowColor = UIColor.blackColor().CGColor
            wrapperView.layer.shadowOpacity = Float(toastShadowOpacity)
            wrapperView.layer.shadowRadius = toastShadowRadius
            wrapperView.layer.shadowOffset = toastShadowOffset
        }

        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .ScaleAspectFit
            imageView!.frame = CGRect(x: toastHorizontalMargin, y: toastVerticalMargin, width: CGFloat(toastImageViewWidth), height: CGFloat(toastImageViewHeight))
        }

        var imageWidth: CGFloat, imageHeight: CGFloat, imageLeft: CGFloat
        if imageView != nil {
            imageWidth = imageView!.bounds.size.width
            imageHeight = imageView!.bounds.size.height
            imageLeft = toastHorizontalMargin
        } else {
            imageWidth  = 0.0; imageHeight = 0.0; imageLeft   = 0.0
        }

        if title != nil {
            titleLabel = UILabel()
            titleLabel!.numberOfLines = toastMaxTitleLines
            titleLabel!.font = UIFont.boldSystemFontOfSize(toastFontSize)
            titleLabel!.textAlignment = .Center
            titleLabel!.lineBreakMode = .ByWordWrapping
            titleLabel!.textColor = UIColor.whiteColor()
            titleLabel!.backgroundColor = UIColor.clearColor()
            titleLabel!.alpha = 1.0
            titleLabel!.text = title

            // size the title label according to the length of the text
            let maxSizeTitle = CGSize(width: (self.bounds.size.width * toastMaxWidth) - imageWidth, height: self.bounds.size.height * toastMaxHeight)
            let expectedWidth = min(maxSizeTitle.width, title!.stringWidth(toastFontSize) - imageWidth)
            let expectedHeight = title!.stringHeight(toastFontSize, width: maxSizeTitle.width)
            titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: expectedWidth, height: expectedHeight)
        }

        if msg != nil {
            msgLabel = UILabel()
            msgLabel!.numberOfLines = toastMaxMessageLines
            msgLabel!.font = UIFont.systemFontOfSize(toastFontSize)
            msgLabel!.lineBreakMode = .ByWordWrapping
            msgLabel!.textAlignment = .Center
            msgLabel!.textColor = UIColor.whiteColor()
            msgLabel!.backgroundColor = UIColor.clearColor()
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg

            let maxSizeMessage = CGSize(width: (self.bounds.size.width * toastMaxWidth) - imageWidth, height: self.bounds.size.height * toastMaxHeight)
            let expectedWidth = min(maxSizeMessage.width, msg!.stringWidth(toastFontSize) - imageWidth)
            let expectedHeight = msg!.stringHeight(toastFontSize, width: maxSizeMessage.width)
            msgLabel!.frame = CGRect(x: 0.0, y: 0.0, width: expectedWidth, height: expectedHeight)
        }

        var titleWidth: CGFloat, titleHeight: CGFloat, titleTop: CGFloat, titleLeft: CGFloat
        if titleLabel != nil {
            titleWidth = titleLabel!.bounds.size.width
            titleHeight = titleLabel!.bounds.size.height
            titleTop = toastVerticalMargin
            titleLeft = imageLeft + imageWidth + toastHorizontalMargin
        } else {
            titleWidth = 0.0; titleHeight = 0.0; titleTop = 0.0; titleLeft = 0.0
        }

        var msgWidth: CGFloat, msgHeight: CGFloat, msgTop: CGFloat, msgLeft: CGFloat
        if msgLabel != nil {
            msgWidth = msgLabel!.bounds.size.width
            msgHeight = msgLabel!.bounds.size.height
            msgTop = titleTop + titleHeight + toastVerticalMargin
            msgLeft = imageLeft + imageWidth + toastHorizontalMargin
        } else {
            msgWidth = 0.0; msgHeight = 0.0; msgTop = 0.0; msgLeft = 0.0
        }

        let largerWidth = max(titleWidth, msgWidth)
        let largerLeft  = max(titleLeft, msgLeft)

        // set wrapper view's frame
        let wrapperWidth  = max(imageWidth + toastHorizontalMargin * 2, largerLeft + largerWidth + toastHorizontalMargin)
        let wrapperHeight = max(msgTop + msgHeight + toastVerticalMargin, imageHeight + toastVerticalMargin * 2)
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)

        // add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRect(x: titleLeft, y: titleTop, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        if msgLabel != nil {
            msgLabel!.frame = CGRect(x: msgLeft, y: msgTop, width: msgWidth, height: msgHeight)
            wrapperView.addSubview(msgLabel!)
        }
        if imageView != nil {
            wrapperView.addSubview(imageView!)
        }

        return wrapperView
    }

}

extension String {

    func stringHeight(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFontOfSize(fontSize)
        let size = CGSize(width: width, height: CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        let attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]

        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }

    func stringWidth(fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFontOfSize(fontSize)
        let text = self as NSString
        let size = text.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
    }

}
