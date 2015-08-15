//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

class UserApi {
    static func request(method: String, body: [String:AnyObject]) -> Request{
        return apiManager.request("user/" + method, body: body)
    }
    static func getCodeMsg(phone: String) -> Request {
        return UserApi.request("getCodeMsg", body: ["phone":phone])
    }
    
    static func login(phone: String, code: String) -> Request {
        return UserApi.request("login", body: ["phone":phone, "code":code])
    }
    
    static func updateInfo(nickname: String, sex: Int, car: String) -> Request {
        return UserApi.request("updateInfo", body: ["nickname":nickname, "sex":sex, "car":car])
    }
}