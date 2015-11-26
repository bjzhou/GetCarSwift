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

    static func praise(sid sid: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("trace/pubComment", body: ["sid":sid, "type":0])
    }

    static func cancelPraise(sid sid: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("trace/canclePraise", body: ["sid":sid])
    }
}
