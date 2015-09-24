//
//  GeoApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct Nearby: JSONable {
    var nickname = ""
    var sex = 0
    var lati = 0.0
    var longt = 0.0
    var car_head_bg = 0
    var car_head_id = 0

    init(json: JSON) {
        nickname = json["nickname"].stringValue
        sex = json["sex"].intValue
        lati = json["lati"].doubleValue
        longt = json["longt"].doubleValue
        car_head_bg = json["car_head_bg"].intValue
        car_head_id = json["car_head_id"].intValue
    }

    static func map(max_count: Int = 10, max_distance: Int = 5000, accelerate: Double, speed: Double) -> Observable<GKResult<Nearby>> {
        return GaikeService.sharedInstance.api("geo/map", body: ["max_count":max_count, "max_distance":max_distance, "acc":accelerate, "speed":speed])
    }
}