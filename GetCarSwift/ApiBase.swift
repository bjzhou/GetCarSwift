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

struct ApiResult<T: ApiResultBase> {
    var code: Int
    var msg: String
    var data: T
    init(json: AnyObject) {
        let json = JSON(json)
        code = json["code"].intValue
        msg = json["msg"].stringValue
        data = T(json: json["data"])
    }
}

protocol ApiResultBase {
    init(json: JSON)
}

extension Manager {
    public func request(
        method: Method,
        _ URLString: URLStringConvertible,
        body: JSON)
        -> Request
        {
            let mutableURLRequest = URLRequest(method, URLString, headers: nil)
            do {
                try mutableURLRequest.HTTPBody = body.rawData()
            } catch {
                print("url reuest error")
            }
            return request(mutableURLRequest)
        }
}
