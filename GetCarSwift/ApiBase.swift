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

let API_DEBUG = true

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
        headers["Ass-lati"] = String(ApiHeader.sharedInstance.location?.coordinate.latitude ?? 0)
        headers["Ass-longti"] = String(ApiHeader.sharedInstance.location?.coordinate.longitude ?? 0)

        if API_DEBUG {
            print("header: \(headers)")
        }

        let mutableURLRequest = URLRequest(.POST, DOMAIN + urlString, headers: headers)
        do {
            try mutableURLRequest.HTTPBody = JSON(body).rawData()
        } catch {
            if API_DEBUG {print("url request error: \(mutableURLRequest.description)")}
        }
        if API_DEBUG {print("request url: \(mutableURLRequest.description)")}
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
                    if API_DEBUG {print(newResult)}
                } else {
                    newResult.error = result.error
                    if API_DEBUG {print(NSString(data: result.data!, encoding: NSUTF8StringEncoding))}
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