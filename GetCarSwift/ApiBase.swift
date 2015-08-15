//
//  ApiBase.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

let DOMAIN = "http://api.gaikit.com:8901/"

let apiManager = Manager.sharedInstance

extension Manager {

    public func request(urlString: String, body: [String:AnyObject]) -> Request {
        var headers: [String:String] = [:]

        headers["Ass-apiver"] = "1.0"
        headers["Ass-appver"] = VERSION_SHORT
        headers["Ass-accesskey"] = ""
        headers["Ass-contentmd5"] = ""
        headers["Ass-signature"] = ""
        headers["Ass-time"] = String(NSDate().timeIntervalSince1970)
        headers["Ass-token"] = ApiHeader.sharedInstance.token ?? ""
        headers["Ass-packagename"] = NSBundle.mainBundle().bundleIdentifier
        headers["Ass-lati"] = String(ApiHeader.sharedInstance.lat ?? 0)
        headers["Ass-longti"] = String(ApiHeader.sharedInstance.longi ?? 0)

        print("header: \(headers)")

        let mutableURLRequest = URLRequest(.POST, DOMAIN + urlString, headers: headers)
        do {
            try mutableURLRequest.HTTPBody = JSON(body).rawData()
        } catch {
            print("url request error: \(mutableURLRequest.description)")
        }
        print("request url: \(mutableURLRequest.description)")
        return request(mutableURLRequest)
    }
}

extension Request {
    public func responseGKJSON(options options: NSJSONReadingOptions = .AllowFragments,completionHandler: (NSURLRequest?, NSHTTPURLResponse?, GKResult) -> Void) -> Self {
        return response(responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { (request, response, result) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                var newResult = GKResult()
                
                if let jsonValue = result.value {
                    let json = JSON(jsonValue)
                    newResult.json = json["data"]
                    newResult.code = json["code"].intValue
                    newResult.msg = json["msg"].stringValue
                    print(newResult)
                } else {
                    newResult.error = result.error
                    print(NSString(data: result.data!, encoding: NSUTF8StringEncoding))
                }
                

                
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(self.request, self.response, newResult)
                })
            })
        })
    }
}

public struct GKResult {
    var json: JSON?
    var code: Int?
    var msg: String?
    var error: NSError?
}