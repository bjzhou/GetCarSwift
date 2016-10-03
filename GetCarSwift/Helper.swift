//
//  Helper.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/11.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

infix operator =?
func =?<T> (left: inout T, right: T?) {
    if let r = right {
        left = r
    }
}
