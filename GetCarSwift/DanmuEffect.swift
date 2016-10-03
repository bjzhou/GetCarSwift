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

    let queue = DispatchQueue(label: "serial-worker\(arc4random())")

    init(superView: UIView, rect: CGRect? = nil) {
        self.superView = superView
        self.rect = rect == nil ? superView.frame : rect!
    }

    private func generateRandom(_ size: CGSize) -> CGFloat {
        let randomPos = CGFloat(arc4random_uniform(UInt32(rect.height - size.height)))
        if abs(lastPos - randomPos) <= size.height {
            return generateRandom(size)
        }
        lastPos = randomPos
        return randomPos
    }

    func send(_ text: String, delay: UInt32 = 0, highlight: Bool = false, highPriority: Bool = false) {
        let closeDanmu = UserDefaults.standard.bool(forKey: "closeDanmu")
        if  closeDanmu {
            return
        }
        (highPriority ? DispatchQueue.global() : queue).async {
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: self.textSize)
            label.textColor = UIColor(rgbValue: UInt(arc4random_uniform(0xffffff+1)))
            if highlight {
                label.textColor = UIColor.black
                label.backgroundColor = UIColor.red
            }
            label.text = text
            let size = label.attributedText?.size() ?? CGSize.zero
            let randomPos = self.generateRandom(size)
            main {
                label.frame = CGRect(x: self.rect.origin.x + self.rect.width, y: self.rect.origin.y + randomPos, width: size.width, height: size.height)
                //label.tag = Int(NSDate().timeIntervalSince1970 * 1000)
                self.superView.addSubview(label)
                UIView.animate(withDuration: self.animDuration, delay: 0, options: .curveLinear, animations: {
                    label.transform = CGAffineTransform(translationX: -self.rect.width-size.width, y: 0)
                    }, completion: { _ in
                        label.removeFromSuperview()
                })
            }
            self._danmuList.append(text)
            sleep(delay)
        }
    }
}
