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

class CarInfo: Object {
    dynamic var model = ""
    dynamic var modelId = ""

    dynamic var id = 0
    dynamic var imageUrl = ""
    dynamic var year = ""
    dynamic var detail = ""
    dynamic var lisence = ""
    dynamic var name = ""
    var parts = List<CarPart>()

    override class func primaryKey() -> String? { return "id" }

    static func info() -> Observable<([String], [String: [String]], [String: [CarInfo]])> {
        //api("info", body: [:], completion: completion)
        return GaikeService.sharedInstance.api("car/info").observeOn(operationScheduler).map { (result: GKResult<JSON>) in
            var categeries: [String] = []
            var brands: [String: [String]] = [:]
            var models: [String: [CarInfo]] = [:]
            guard let json = result.data else {
                return (categeries, brands, models)
            }

            categeries = json.sortedDictionaryKeys() ?? []
            for categery in categeries {
                brands[categery] = json[categery].sortedDictionaryKeys() ?? []
                for brand in brands[categery]! {
                    if let strs = json[categery, brand].arrayObject as? [String] {
                        var cars = [CarInfo]()
                        for i in 0..<strs.count {
                            if i % 2 == 0 {
                                cars.append(CarInfo())
                                cars[i/2].modelId = strs[i]
                            } else {
                                cars[i/2].model = strs[i]
                            }
                        }
                        models[brand] = cars
                    }
                }
            }

            return (categeries, brands, models)
            }.observeOn(MainScheduler.sharedInstance)
    }
}

class CarPart: Object {
    dynamic var imageKey = NSUUID().UUIDString
    dynamic var title = ""
    dynamic var detail = ""
}
