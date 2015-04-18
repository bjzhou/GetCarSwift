//
//  FileUtils.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/18.
//  Copyright (c) 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

func saveImage(image: UIImage, filename: String) {
    var data = UIImagePNGRepresentation(image)
    data.writeToFile(getFilePath(filename), atomically: true)
}

func getFilePath(filename: String) -> String {
    var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    return paths[0].stringByAppendingPathComponent(filename)
}

func scaleImage(image: UIImage, scale: CGFloat) -> UIImage {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scale, image.size.height * scale))
    image.drawInRect(CGRectMake(0, 0, image.size.width * scale, image.size.height * scale))
    var newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

func scaleImage(image: UIImage, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    image.drawInRect(CGRectMake(0, 0, size.width, size.height))
    var newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}