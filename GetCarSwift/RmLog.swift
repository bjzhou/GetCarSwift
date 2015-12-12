//
//  RmLog.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/11.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RealmSwift

class RmLog: Object {
    dynamic var time: String = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.stringFromDate(NSDate())
    }()
    dynamic var level = ""
    dynamic var message = ""

    private static let realm = try! Realm()

    private static func log(level: String, message: String) {
        #if ADHOC
        try! realm.write {
            realm.add(RmLog(value: ["level": level, "message": message]))
        }
        #endif
    }

    class func d(message: String) {
        log("D", message: message)
    }

    class func v(message: String) {
        log("V", message: message)
    }

    class func w(message: String) {
        log("W", message: message)
    }

    class func e(message: String) {
        log("E", message: message)
    }

    class func i(message: String) {
        log("I", message: message)
    }
}
