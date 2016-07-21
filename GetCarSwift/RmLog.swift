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
    dynamic var time = Date()
    dynamic var level = ""
    dynamic var message = ""

    private static func log(_ level: String, message: String) {
        gRealm?.writeOptional {
            gRealm?.add(RmLog(value: ["level": level, "message": message]))
        }
    }

    class func d(_ message: String) {
        #if DEBUG
            print("💚", message)
        #endif
        BuglyLog.level(BuglyLogLevel.debug, logs: message)
        log("D", message: message)
    }

    class func v(_ message: String) {
        #if DEBUG
            print("💜", message)
        #endif
        BuglyLog.level(BuglyLogLevel.verbose, logs: message)
        log("V", message: message)
    }

    class func w(_ message: String) {
        #if DEBUG
            print("💛", message)
        #endif
        BuglyLog.level(BuglyLogLevel.warn, logs: message)
        log("W", message: message)
    }

    class func e(_ message: String) {
        #if DEBUG
            print("❤️", message)
        #endif
        BuglyLog.level(BuglyLogLevel.error, logs: message)
        log("E", message: message)
    }

    class func i(_ message: String) {
        #if DEBUG
            print("💙", message)
        #endif
        BuglyLog.level(BuglyLogLevel.info, logs: message)
        log("I", message: message)
    }
}
