//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct User: JSONable {
    var phone: String?
    var id: String?
    var car: String?
    var nickname: String?
    var sex: Int?
    var img: String?
    var token: String?

    init(json: JSON) {
        phone = json["phone"].string
        id = json["id"].string
        car = json["car"].string
        nickname = json["nickname"].string
        sex = json["sex"].string?.intValue
        img = json["img"].string
        token = json["token"].string

        if let wrappedImg = img {
            if !wrappedImg.hasPrefix("http://") {
                img = "http://pic.gaikit.com/user/head/" + wrappedImg
            }
        }
    }

    static func getCodeMsg(phone: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/getCodeMsg", body: ["phone":phone])
    }

    static func login(phone phone: String, code: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/login", body: ["phone":phone, "code":code])
    }

    static func updateInfo(nickname nickname: String, sex: Int, car: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/updateInfo", body: ["nickname":nickname, "sex":sex, "car":car])
    }

    static func updateInfo(color color: String, icon: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/updateInfo", body: ["car_head_bg":color, "car_head_id":icon])
    }

    static func uploadHeader(image: UIImage) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.upload("upload/uploadHeader", datas: ["pictures":UIImagePNGRepresentation(image)!])
    }
}