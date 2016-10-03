//
//  Async.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation


let serialQueue = DispatchQueue(label: "serial-worker")

func async(serial: Bool = false, closure: @escaping () -> Void) {
    let queue = serial ? serialQueue : DispatchQueue.global()
    queue.async(execute: closure)
}

func main(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func delay(_ timeInterval: TimeInterval, closure: @escaping ()->()) {
    let when = DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
