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

    public func request(urlString: String, body: [String:AnyObject]) -> Request {
            var headers: [String:String] = [:]
            if let token = ApiHeader.sharedInstance.token {
                headers["token"] = token
            }
            
            if let lat = ApiHeader.sharedInstance.lat {
                headers["lat"] = String(lat)
            }
            
            if let longi = ApiHeader.sharedInstance.longi {
                headers["longi"] = String(longi)
            }

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