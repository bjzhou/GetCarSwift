//
//  FileUtils.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/18.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UIImage {
    func scaleImage(scale scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.size.width * scale, height: self.size.height * scale))
        self.drawInRect(CGRect(x: 0, y: 0, width: self.size.width * scale, height: self.size.height * scale))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func scaleImage(size size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    class func WithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    class func asyncInit(name: String, closure: UIImage? -> ()) {
        dispatch_async(serialQueue) {
            let img = UIImage(named: name)
            mainThread {
                closure(img)
            }
        }
    }
}
