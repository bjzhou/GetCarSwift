//
//  String.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/8.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

extension String: JSONable {
    init(json: JSON) {
        self.init(json.stringValue)
    }
}