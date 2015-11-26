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
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scale, self.size.height * scale))
        self.drawInRect(CGRectMake(0, 0, self.size.width * scale, self.size.height * scale))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func scaleImage(size size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    class func WithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
