//
//  Async.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation


let serialQueue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)

func async(serial serial: Bool = false, closure: () -> Void) {
    let queue = serial ? serialQueue : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    dispatch_async(queue, closure)
}

func main(closure: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), closure)
}

func delay(timeInterval: NSTimeInterval, closure: dispatch_block_t) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}
