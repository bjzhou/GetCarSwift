//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

var str = "Hello, playground"

var array = [0, 1, 2, 3] {
    didSet {
        print(array)
    }
}

array[0] = 1
array.append(4)

var lazy: Int {
    let r = 1
    print(r+1)
    return r+1
}

print(lazy)
print(lazy+1)

let queue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)
func async(bgThread: () -> Void) {
    dispatch_async(queue, bgThread)
}

var asyncA = 0
for i in 0...10 {
    async {
        print(asyncA)
        asyncA++
        sleep(1)
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
