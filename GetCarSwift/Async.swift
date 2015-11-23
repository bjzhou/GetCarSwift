//
//  Async.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

infix operator ~> {}

func ~>(bgThread: () -> (), mainThread: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        bgThread()
        dispatch_async(dispatch_get_main_queue(), mainThread)
    }
}

func ~><T>(bgThread: () -> T, mainThread: (result: T) -> ()) {
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