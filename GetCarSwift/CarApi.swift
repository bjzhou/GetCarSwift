//
//  CarApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/15.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

class CarApi {
    static func request(method: String, body: [String:AnyObject]) -> Request{
        return apiManager.request("car/" + method, body: body)
    }
    
    static func info() -> Request {
        return request("info", body: [:])
    }
}