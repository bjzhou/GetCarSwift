//
//  Async.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation


let serialQueue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)

infix operator ~> {}

func ~> (bgThread: () -> (), mainThread: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        bgThread()
        dispatch_async(dispatch_get_main_queue(), mainThread)
    }
}

func ~><T> (bgThread: () -> T, mainThread: (result: T) -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        let result = bgThread()
        dispatch_async(dispatch_get_main_queue()) {
            mainThread(result: result)
        }
    }
}

func async(bgThread: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), bgThread)
}

func mainThread(main: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), main)
}

func delay(timeInterval: NSTimeInterval, block: dispatch_block_t) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), block)
}
