//
//  DanmuEffect.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class DanmuEffect {

    let superView: UIView
    let rect: CGRect

    var textSize: CGFloat = 17.0
    var animDuration = 5.0
    var danmuList: [String] {
        return _danmuList
    }

    private var _danmuList = [String]()
    private var lastPos: CGFloat = 0.0

    let queue = dispatch_queue_create("serial-worker\(random())", DISPATCH_QUEUE_SERIAL)

    init(superView: UIView, rect: CGRect? = nil) {
        self.superView = superView
        self.rect = rect == nil ? superView.frame : rect!
    }

    private func generateRandom(size: CGSize) -> CGFloat {
        let randomPos = CGFloat(arc4random_uniform(UInt32(rect.height - size.height)))
        if abs(lastPos - randomPos) <= size.height {
            return generateRandom(size)
        }
        lastPos = randomPos
        return randomPos
    }

    func send(text: String, delay: UInt32 = 0, highlight: Bool = false, highPriority: Bool = false) {
        let closeDanmu = NSUserDefaults.standardUserDefaults().boolForKey("closeDanmu")
        if  closeDanmu {
            return
        }
        dispatch_async(highPriority ? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) : queue) {
            let label = UILabel()
            label.font = UIFont.boldSystemFontOfSize(self.textSize)
            label.textColor = UIColor(rgbValue: UInt(arc4random_uniform(0xffffff+1)))
            if highlight {
                label.textColor = UIColor.blackColor()
                label.backgroundColor = UIColor.redColor()
            }
            label.text = text
            let size = label.attributedText?.size() ?? CGSizeZero
            let randomPos = self.generateRandom(size)
            main {
                label.frame = CGRect(x: self.rect.origin.x + self.rect.width, y: self.rect.origin.y + randomPos, width: size.width, height: size.height)
                //label.tag = Int(NSDate().timeIntervalSince1970 * 1000)
                self.superView.addSubview(label)
                UIView.animateWithDuration(self.animDuration, delay: 0, options: .CurveLinear, animations: {
                    label.transform = CGAffineTransformMakeTranslation(-self.rect.width-size.width, 0)
                    }, completion: { _ in
                        label.removeFromSuperview()
                })
            }
            self._danmuList.append(text)
            sleep(delay)
        }
    }
}
