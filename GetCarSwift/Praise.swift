//
//  Praise.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct Praise: JSONable {
    var uid = ""

    init(json: JSON) {
        uid = json["uid"].stringValue
    }

    // 0: 取消
    // 1: 点赞
    static func praise(sid sid: Int, status: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("trace/praise", body: ["sid":sid, "status":status])
    }

    static func getPraiseList() -> Observable<GKResult<PraiseCount>> {
        return GaikeService.sharedInstance.api("trace/getPraiseList")
    }
}

struct PraiseCount: JSONable {
    var sid = 0
    var count = 0
    var status = 0

    init(json: JSON) {
        sid = json["sid"].intValue
        count = json["count"].intValue
        status = json["status"].intValue
    }
}
