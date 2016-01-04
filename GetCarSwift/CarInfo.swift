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
    dynamic var model = ""
    dynamic var modelId = 0

    dynamic var id = 0
    dynamic var carUserId = 0
    dynamic var imageUrl = ""
    dynamic var year = ""
    dynamic var detail = ""
    dynamic var lisence = ""
    dynamic var name = ""
    var parts = List<CarPart>()

    convenience required init(json: JSON) {
        self.init()
        self.carUserId = json["id"].intValue
        self.modelId = json["car_id", 0, "id"].intValue
        self.model = json["car_id", 0, "model"].stringValue
        self.year = json["car_year"].stringValue
        self.lisence = json["car_number"].stringValue
        self.name = json["car_username"].stringValue
        self.detail = json["car_version"].stringValue
    }

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
                                cars[i/2].modelId = Int(strs[i]) ?? 0
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

    static func addUserCar(carId: Int, number: String = "", username: String = "", year: String = "", version: String = "") -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.api("car/addUserCar", body: ["car_id": carId, "car_number": number, "car_username": username, "car_year": year, "car_version": version])
    }

    static func deleteUserCar(userCarId: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("car/deleteUserCar", body: ["user_car_id": userCarId])
    }

    static func getUserCar() -> Observable<GKResult<CarInfo>> {
        return GaikeService.sharedInstance.api("car/getUserCar")
    }

    static func updateUserCar(userCarId: Int, carId: Int, number: String, username: String, year: String, version: String) -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.api("car/updateUserCar", body: ["user_car_id": userCarId, "car_id": carId, "car_number": number, "car_username": username, "car_year": year, "car_version": version])
    }

    static func addUserCarPart(userCarId: Int, name: String, desc: String, img: UIImage) -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.upload("car/addUserCarPart", parameters: ["user_car_id": userCarId, "name": name, "desc": desc], datas: ["img": UIImagePNGRepresentation(img)!])
    }

    static func deleteUserCarPart(userCarPartId: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("car/deleteUserCarPart", body: ["user_car_part_id": userCarPartId])
    }

    static func getUserCarPart(userCarId: Int) -> Observable<GKResult<CarPart>> {
        return GaikeService.sharedInstance.api("car/getUserCarPart", body: ["user_car_id": userCarId])
    }

    static func updateUserCarPart(userCarPartId: Int, userCarId: Int, name: String, desc: String, img: UIImage) -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.upload("car/updateUserCarPart", parameters: ["user_car_part_id": userCarPartId, "user_car_id": userCarId, "name": name, "desc": desc], datas: ["img": UIImagePNGRepresentation(img)!])
    }
}

class CarPart: Object, JSONable {
    dynamic var id = 0
    dynamic var userCarId = 0
    dynamic var imageUrl = ""
    dynamic var title = ""
    dynamic var detail = ""

    convenience required init(json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.userCarId = json["user_car_id"].intValue
        self.title = json["name"].stringValue
        self.detail = json["desc"].stringValue
        self.imageUrl = json["img"].stringValue

        if imageUrl != "" && !imageUrl.hasPrefix("http://") {
            self.imageUrl = "http://pic.gaikit.com/" + self.imageUrl
        }
    }
}
