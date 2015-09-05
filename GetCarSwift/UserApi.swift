//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class UserApi {
    static let PREFIX = "user/"

    class func getCodeMsg(phone: String, completion: GKResult -> Void) {
        api(PREFIX + "getCodeMsg", body: ["phone":phone], completion: completion)
    }

    class func login(phone phone: String, code: String, completion: GKResult -> Void) {
        api(PREFIX + "login", body: ["phone":phone, "code":code], completion: completion)
    }

    class func updateInfo(nickname nickname: String, sex: Int, car: String, completion: GKResult -> Void) {
        api(PREFIX + "updateInfo", body: ["nickname":nickname, "sex":sex, "car":car], completion: completion)
    }

    class func updateInfo(color color: String, icon: String, completion: GKResult -> Void) {
        api(PREFIX + "updateInfo", body: ["color":color, "icon":icon], completion: completion)
    }
}