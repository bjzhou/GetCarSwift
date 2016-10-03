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
    var uid = ""
    var nickname = ""
    var sex = 0
    var lati = 0.0
    var longt = 0.0
    var headUrl = ""
    var friendStatus = 0 // 0: 好友 1: 已关注 2: 被关注
    var carHeadBg = 0
    var carHeadId = 0

    init(json: JSON) {
        uid = json["id"].stringValue
        nickname = json["nickname"].stringValue
        sex = json["sex"].intValue
        lati = json["lati"].doubleValue
        longt = json["longt"].doubleValue
        headUrl = json["head_url"].stringValue
        friendStatus = json["friend_status"].intValue
        carHeadBg = json["car_head_bg"].intValue
        carHeadId = json["car_head_id"].intValue
    }

    static func map(_ maxCount: Int = 25, maxDistance: Int = 5000) -> Observable<GKResult<Nearby>> {
        return GaikeService.sharedInstance.api("geo/map", body: ["max_count":String(maxCount), "max_distance":String(maxDistance)])
    }
}
