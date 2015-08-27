//
//  UIColor.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/8.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(rgbValue: UInt) {
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func gaikeRedColor() -> UIColor {
        return UIColor(rgbValue: 0xcc0007)
    }
    
    static func gaikeBackgroundColor() -> UIColor {
        return UIColor(rgbValue: 0xeeeeee)
    }
}