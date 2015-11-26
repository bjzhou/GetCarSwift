//
//  CarApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/15.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct CarInfo: JSONable {
    var category = "#"
    var brand = ""
    var model = ""
    var modelId = ""

    init(json: JSON) {
        category = json["categery"].stringValue
        brand = json["brand"].stringValue
        model = json["model"].stringValue
        modelId = json["id"].stringValue
    }

    static func info() -> Observable<GKResult<CarInfo>> {
        //api("info", body: [:], completion: completion)
        return GaikeService.sharedInstance.api("car/info")
    }
}
