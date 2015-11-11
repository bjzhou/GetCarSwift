//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

var a = Variable(11)
var b = Variable(22)

combineLatest(a, b) { a,b in
    return (a, b)
    }.map { a,b in
        return a+b
    }.subscribeNext { (c:Int) in
        print(c)
}

a.value = 1
b.value = 2
a.value = 3
a.value = 5
a.value = 8

String(0)

round(0.51)

var array = [0, 1, 2, 3] {
    didSet {
        print(array)
    }
}

array[0] = 1
array.append(4)
