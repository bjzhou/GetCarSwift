//
//  GeoApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

func map(max_count: Int = 10, max_distance: Int = 5, accelerate: Int, speed: Int) -> Request {
    return apiManager.request("geo/map", body: ["max_count":max_count, "max_distance":max_distance, "accelerate":accelerate, "speed":speed])
}