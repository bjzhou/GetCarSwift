//
//  GeoApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class GeoApi: GaikeService {
    static let sharedInstance = GeoApi()

    override func path() -> String {
        return "geo/"
    }

    func map(max_count: Int = 10, max_distance: Int = 5000, accelerate: Double, speed: Double, completion: GKResult -> Void) {
        api("map", body: ["max_count":max_count, "max_distance":max_distance, "acc":accelerate, "speed":speed], completion: completion)
    }
}