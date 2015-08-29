//
//  ApiBase.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Haneke

let DOMAIN = "http://api.gaikit.com:8901/"

let apiManager = Manager.sharedInstance
let apiCache = Shared.GKResultCache

let API_DEBUG = true

func api(urlString: String, body: [String:AnyObject], completion: GKResult -> Void) {
    var headers: [String:String] = [:]

    headers["Ass-apiver"] = "1.0"
    headers["Ass-appver"] = VERSION_SHORT
    headers["Ass-accesskey"] = ""
    headers["Ass-contentmd5"] = ""
    headers["Ass-signature"] = ""
    headers["Ass-time"] = String(NSDate().timeIntervalSince1970)
    headers["Ass-token"] = ApiHeader.sharedInstance.token ?? ""
    headers["Ass-packagename"] = NSBundle.mainBundle().bundleIdentifier
    headers["Ass-lati"] = String(ApiHeader.sharedInstance.location?.coordinate.latitude ?? 0)
    headers["Ass-longti"] = String(ApiHeader.sharedInstance.location?.coordinate.longitude ?? 0)

    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: DOMAIN + urlString)!)
    mutableURLRequest.HTTPMethod = "POST"
    for (headerField, headerValue) in headers {
        mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
    }
    do {
        try mutableURLRequest.HTTPBody = JSON(body).rawData()
    } catch {
        if API_DEBUG {print("url request error: \(mutableURLRequest.description)")}
    }

    apiManager.request(mutableURLRequest).response { (req, res, data, err) in
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

            var result = GKResult()

            if let data = data {
                if let _ = err {
                    if API_DEBUG {print(NSString(data: data, encoding: NSUTF8StringEncoding))}
                } else {
                    result = GKResult(json: JSON(data: data))
                }
            }

            result.error = err
            if API_DEBUG {print(result)}

            dispatch_async(dispatch_get_main_queue(), {
                completion(result)
            })
        })
    }
}

extension GKResult: DataConvertible, DataRepresentable {
    public typealias Result = GKResult

    public static func convertFromData(data:NSData) -> Result? {
        let json = SwiftyJSON.JSON(data: data)
        return GKResult(json: json)
    }

    public func asData() -> NSData! {
        return try! self.rawJSON?.rawData()
    }
}

extension Shared {
    public static var GKResultCache : Cache<GKResult> {
        struct Static {
            static let name = "shared-gkresult"
            static let cache = Cache<GKResult>(name: name)
        }
        return Static.cache
    }
}

class GKFetcher : Fetcher<GKResult> {
    let body: [String:AnyObject]
    let urlString: String

    init(urlString: String, body: [String:AnyObject]) {
        let key = ParameterEncoding.URL.encode(NSMutableURLRequest(URL: NSURL(string: urlString)!), parameters: body).0.URLString
        self.body = body
        self.urlString = urlString
        super.init(key: key)
    }

    override func fetch(failure fail : ((NSError?) -> ()), success succeed : (GKResult.Result) -> ()) {
        api(urlString, body: body) { result in
            if let err = result.error {
                fail(err)
            } else {
                succeed(result)
            }
        }
    }

    override func cancelFetch() {}
}

public struct GKResult {
    var data: SwiftyJSON.JSON?
    var code: Int?
    var msg: String?
    var error: NSError?

    var rawJSON: SwiftyJSON.JSON?

    init(json: SwiftyJSON.JSON) {
        code = json["code"].intValue
        msg = json["msg"].stringValue
        data = json["data"]

        rawJSON = json
    }

    init() {
    }
}