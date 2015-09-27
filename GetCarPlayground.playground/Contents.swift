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