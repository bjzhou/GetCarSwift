//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

var a = Variable(11)
var b = Variable(22)

zip(a, b) { a,b in
    return (a, b)
    }.map { a,b in
        return a+b
    }.subscribeNext { (c:Int) in
        print(c)
}.dispose()

a.value = 13
b.value = 16

a.value = 14
b.value = 25
