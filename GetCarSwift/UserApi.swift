//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class UserApi: GaikeService {
    static let sharedInstance = UserApi()

    override func path() -> String {
        return "user/"
    }

    func getCodeMsg(phone: String, completion: GKResult -> Void) {
        api("getCodeMsg", body: ["phone":phone], completion: completion)
    }

    func login(#phone: String, code: String, completion: GKResult -> Void) {
        api("login", body: ["phone":phone, "code":code], completion: completion)
    }

    func updateInfo(#nickname: String, sex: Int, car: String, completion: GKResult -> Void) {
        api("updateInfo", body: ["nickname":nickname, "sex":sex, "car":car], completion: completion)
    }

    func updateInfo(#color: String, icon: String, completion: GKResult -> Void) {
        api("updateInfo", body: ["car_head_bg":color, "car_head_id":icon], completion: completion)
    }
}