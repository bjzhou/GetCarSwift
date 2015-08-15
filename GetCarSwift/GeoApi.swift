//
//  GeoApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

class GeoApi {
    static func request(method: String, body: [String:AnyObject]) -> Request{
        return apiManager.request("geo/" + method, body: body)
    }
    static func map(max_count: Int = 10, max_distance: Int = 5000, accelerate: Double, speed: Double) -> Request {
        return GeoApi.request("map", body: ["max_count":max_count, "max_distance":max_distance, "acc":accelerate, "speed":speed])
    }
}