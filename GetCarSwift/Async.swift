//
//  Async.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation


let serialQueue = DispatchQueue(label: "serial-worker", attributes: DispatchQueueAttributes.serial)

func async(serial: Bool = false, closure: () -> Void) {
    let queue = serial ? serialQueue : DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosBackground)
    queue.async(execute: closure)
}

func main(_ closure: () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func delay(_ timeInterval: TimeInterval, closure: ()->()) {
    let when = DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.after(when: when, execute: closure)
}
