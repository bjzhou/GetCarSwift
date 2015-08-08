//
//  String.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/8.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    var intValue: Int {
        return (self as NSString).integerValue
    }
}