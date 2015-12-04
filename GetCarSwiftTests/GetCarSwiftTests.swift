//
//  GetCarSwiftTests.swift
//  GetCarSwiftTests
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import XCTest
import RealmSwift
@testable import GetCarSwift

class GetCarSwiftTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRmScore() {
        let realm = try! Realm()
        let score1 = RmScore()
        score1.mapType = 9001
        score1.score = 1.2
        let score2 = RmScore()
        score2.mapType = 9001
        score2.score = 1.2
        let score3 = RmScore()
        score3.mapType = 9001
        score3.score = 1.2
        try! realm.write {
            realm.add(score1)
            realm.add(score2)
            realm.add(score3)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
