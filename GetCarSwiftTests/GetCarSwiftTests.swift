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
            "phone": 18657904839,
            "code": 4287
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
        Manager.sharedInstance.request(.POST, "http://api.gaikit.com/user/login", parameters: ["phone": 18657904839, "code": 4287], encoding: .JSON, headers: nil).responseString { (res) -> Void in
            print(res.result.value, res.result.error)
            expect.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

}
