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
    dynamic var time = NSDate()
    dynamic var level = ""
    dynamic var message = ""

    private static func log(level: String, message: String) {
        gRealm?.writeOptional {
            gRealm?.add(RmLog(value: ["level": level, "message": message]))
        }
    }

    class func d(message: String) {
        #if DEBUG
            print("💚", message)
        #endif
        BuglyLog.level(BLYLogLevel.Debug, logs: message)
        log("D", message: message)
    }

    class func v(message: String) {
        #if DEBUG
            print("💜", message)
        #endif
        BuglyLog.level(BLYLogLevel.Verbose, logs: message)
        log("V", message: message)
    }

    class func w(message: String) {
        #if DEBUG
            print("💛", message)
        #endif
        BuglyLog.level(BLYLogLevel.Warn, logs: message)
        log("W", message: message)
    }

    class func e(message: String) {
        #if DEBUG
            print("❤️", message)
        #endif
        BuglyLog.level(BLYLogLevel.Error, logs: message)
        log("E", message: message)
    }

    class func i(message: String) {
        #if DEBUG
            print("💙", message)
        #endif
        BuglyLog.level(BLYLogLevel.Info, logs: message)
        log("I", message: message)
    }
}
