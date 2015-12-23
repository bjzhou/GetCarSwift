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
import RealmSwift

class CarInfo: Object, JSONable {
    dynamic var category = "#"
    dynamic var brand = ""
    dynamic var model = ""
    dynamic var modelId = ""

    dynamic var id = 0
    dynamic var imageUrl = ""
    dynamic var year = ""
    dynamic var detail = ""
    dynamic var lisence = ""
    dynamic var name = ""
    var parts = List<CarPart>()

    convenience required init(json: JSON) {
        self.init()
        category = json["categery"].stringValue
        brand = json["brand"].stringValue
        model = json["model"].stringValue
        modelId = json["id"].stringValue
    }

    override class func primaryKey() -> String? { return "id" }

    static func info() -> Observable<GKResult<JSON>> {
        //api("info", body: [:], completion: completion)
        return GaikeService.sharedInstance.api("car/info")
    }
}

class CarPart: Object {
    dynamic var imageKey = NSUUID().UUIDString
    dynamic var title = ""
    dynamic var detail = ""
}
