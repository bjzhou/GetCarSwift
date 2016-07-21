//
//  NSDate+GK.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

extension Date {
    static var nowString: String {
        return "刚刚"
    }

    func optimizedString() -> String {
        let now = Date().timeIntervalSince1970
        let time = self.timeIntervalSince1970
        switch (now - time) {
        case let x where x <= 60:
            return "刚刚"
        case let x where x <= 60 * 60:
            return "\(x/60)分钟前"
        case let x where x <= 60 * 60 * 24:
            return "\(x/60/60)小时前"
        case let x where x <= 60 * 60 * 24 * 2:
            return "昨天"
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-DD HH:mm:ss"
            return dateFormatter.string(from: Date(timeIntervalSince1970: time))
        }
    }
}
