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
    var carHeadBg = 0
    var carHeadId = 0

    init(json: JSON) {
        nickname = json["nickname"].stringValue
        sex = json["sex"].intValue
        lati = json["lati"].doubleValue
        longt = json["longt"].doubleValue
        carHeadBg = json["car_head_bg"].intValue
        carHeadId = json["car_head_id"].intValue
    }

    static func map(maxCount: Int = 10, maxDistance: Int = 5000, accelerate: Double, speed: Double) -> Observable<GKResult<Nearby>> {
        return GaikeService.sharedInstance.api("geo/map", body: ["max_count":maxCount, "max_distance":maxDistance, "acc":accelerate, "speed":speed])
    }
}
