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
    var parts = [CarPart]()

    convenience required init(json: JSON) {
        self.init()
        self.carUserId = json["id"].intValue
        self.modelId = json["car_id", 0, "id"].intValue
        self.model = json["car_id", 0, "model"].stringValue
        self.imageUrl = json["car_id", 0, "logo"].stringValue
        self.year = json["car_year"].stringValue
        self.lisence = json["car_number"].stringValue
        self.name = json["car_username"].stringValue
        self.detail = json["car_version"].stringValue
    }

    func fetchParts(_ closure: @escaping () -> Void) {
        _ = CarInfo.getUserCarPart(carUserId).subscribe(onNext: { res in
            guard let parts = res.dataArray else {
                return
            }

            self.parts = parts
            closure()
        })
    }

    override class func primaryKey() -> String? { return "id" }

    static func infoLogo() -> Observable<([String], [String: [String]], [String: [CarInfo]])> {
        //api("info", body: [:], completion: completion)
        return GaikeService.sharedInstance.api("car/infoLogo").observeOn(operationScheduler).map { (result: GKResult<JSON>) in
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
                            if i % 3 == 0 {
                                cars.append(CarInfo())
                                cars[i/3].modelId = Int(strs[i]) ?? 0
                            } else if i % 3 == 1 {
                                cars[i/3].model = strs[i]
                            } else {
                                cars[i/3].imageUrl = strs[i]
                            }
                        }
                        models[brand] = cars
                    }
                }
            }

            return (categeries, brands, models)
            }.observeOn(MainScheduler.instance)
    }

    static func addUserCar(_ carId: Int, number: String = "", username: String = "", year: String = "", version: String = "") -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.api("car/addUserCar", body: ["car_id": String(carId), "car_number": number, "car_username": username, "car_year": year, "car_version": version])
    }

    static func deleteUserCar(_ userCarId: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("car/deleteUserCar", body: ["user_car_id": String(userCarId)])
    }

    static func getUserCar() -> Observable<GKResult<CarInfo>> {
        return GaikeService.sharedInstance.api("car/getUserCar")
    }

    static func updateUserCar(_ userCarId: Int, carId: Int, number: String, username: String, year: String, version: String) -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.api("car/updateUserCar", body: ["user_car_id": String(userCarId), "car_id": String(carId), "car_number": String(number), "car_username": username, "car_year": year, "car_version": version])
    }

    static func addUserCarPart(_ userCarId: Int, name: String, desc: String, img: UIImage) -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.upload("car/addUserCarPart", parameters: ["user_car_id": String(userCarId), "name": name, "desc": desc], datas: ["img": UIImagePNGRepresentation(img)!])
    }

    static func deleteUserCarPart(_ userCarPartId: Int) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("car/deleteUserCarPart", body: ["user_car_part_id": String(userCarPartId)])
    }

    static func getUserCarPart(_ userCarId: Int) -> Observable<GKResult<CarPart>> {
        return GaikeService.sharedInstance.api("car/getUserCarPart", body: ["user_car_id": String(userCarId)])
    }

    static func updateUserCarPart(_ userCarPartId: Int, userCarId: Int, name: String, desc: String, img: UIImage) -> Observable<GKResult<JSON>> {
        return GaikeService.sharedInstance.upload("car/updateUserCarPart", parameters: ["user_car_part_id": String(userCarPartId), "user_car_id": String(userCarId), "name": name, "desc": desc], datas: ["img": UIImagePNGRepresentation(img)!])
    }
}

struct CarPart: JSONable {
    var id = 0
    var userCarId = 0
    var imageUrl = ""
    var title = ""
    var detail = ""

    init() {}

    init(json: JSON) {
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
