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
import Alamofire
import RxSwift
import SwiftyJSON
@testable import GetCarSwift

// swiftlint:disable force_try
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

    func testGetCodeMsg() {
        let expect = expectationWithDescription("req")
        let params = "{\"phone\": 18657901235}"
        Manager.sharedInstance.request(.GET, "http://api.gaikit.com/user/getCodeMsg?content=\(params.encodedUrlString)").responseString { (res) -> Void in
            print(res.result.value, res.result.error)
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testGetCodeMsg2() {
        let expect = expectationWithDescription("req")
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "4fd6e64b-8c30-9bfb-ce6b-1ee390540497"
        ]
        let parameters = [
            "phone": "18657904839",
            "code": "4287"
        ]

        let postData = try! NSJSONSerialization.dataWithJSONObject(parameters, options: [])

        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.gaikit.com/user/login")!,
            cachePolicy: .UseProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData

        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                print(String(data: data!, encoding: NSUTF8StringEncoding))
            }
            expect.fulfill()
        })

        dataTask.resume()
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testGetCodeMsg3() {
        let expect = expectationWithDescription("req")
        Manager.sharedInstance.request(.POST, "http://api.gaikit.com/user/login", parameters: ["phone": "18657904839", "code": "4287"], encoding: .JSON, headers: nil).responseString { (res) -> Void in
            print(res.result.value, res.result.error)
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testUploadScore() {
        let expect = expectationWithDescription("req")
        let score = RmScore(value: ["mapType": 0, "score": 8.9, "data": [["t": 0, "v": 0, "s": 0], ["t": 2, "v": 20, "s": 50], ["t": 4, "v": 40, "s": 100], ["t": 6, "v": 60, "s": 200], ["t": 8, "v": 80, "s": 300], ["t": 11.1, "v": 100, "s": 400]]])
        _ = Records.uploadRecord(0, duration: 11.1, recordData: score.archive()).subscribeNext { res in
            if let newScore = res.data {
                gRealm?.writeOptional {
                    score.id = newScore.id
                    score.url = newScore.url
                    gRealm?.add(score, update: true)
                }
                print(score)
            }
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testUploadShare() {
        let expect = expectationWithDescription("req")
        _ = Share.uploadShare("11.21", liushikm: "3.12", yibaikm: "7.81", maxa: "5", maxv: "121", title: "这是什么", userCarId: 111, carDesc: "好车").subscribeNext { res in
            if let share = res.data where share.id != "" {
                UIApplication.sharedApplication().openURL(share.getShareUrl())
            } else {
                XCTAssert(false, "response error")
            }
            print(res)
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

//    func testRongIMClient() {
//        let expect = expectationWithDescription("req")
//        let token = "DNxvK68aAlxkfimLWQ5t4fU2FYEUPo/JCfkeXaxWG4EO2EPlJV+HuXLLvABQq7YIdnl7NWqhWKOpH9Pdqh1Ewg=="
//        RCIM.sharedRCIM().connectWithToken(token, success: { str in
//            print(str)
//            expect.fulfill()
//            }, error: { err in
//                XCTAssert(false, "error: \(err)")
//            }, tokenIncorrect: {
//                XCTAssert(false, "token incorrect")
//        })
//        waitForExpectationsWithTimeout(10, handler: nil)
//    }

//    func testSwiftyJSONInt() {
//        let jsonStr = "{\"sex\": \"1\"}".dataUsingEncoding(NSUTF8StringEncoding)
//        let json = JSON(data: jsonStr!)
//        XCTAssertEqual(json["sex"].intValue, 1)
//        XCTAssertEqual(json["sex"].int, .Some(1))
//    }

    func testAddUserCar() {
        let expect = expectationWithDescription("req")
        _ = CarInfo.addUserCar(15, number: "", username: "周斌佳", year: "2016", version: "高配版").subscribeNext { res in
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testGetUserCar() {
        let expect = expectationWithDescription("req")
        _ = CarInfo.getUserCar().subscribeNext { res in
            if let cars = res.dataArray {
                print(cars)
            }
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testDeleteUserCar() {
        let expect = expectationWithDescription("req")
        _ = CarInfo.deleteUserCar(5).subscribeNext { res in
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testAddUserCarPart() {
        let expect = expectationWithDescription("req")
        _ = CarInfo.addUserCarPart(4, name: "配件", desc: "配件详情", img: R.image.about_bg!).subscribeNext { res in
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testGetUserCarPart() {
        let expect = expectationWithDescription("req")
        _ = CarInfo.getUserCarPart(4).subscribeNext { res in
            if let parts = res.dataArray {
                print(parts)
            }
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testDeleteUserCarPart() {
        let expect = expectationWithDescription("req")
        _ = CarInfo.deleteUserCarPart(4).subscribeNext { res in
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(5, handler: nil)
    }

}
