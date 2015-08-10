//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

struct CodeMsg: ApiResultBase {
    var code: String
    init(json: JSON) {
        code = json["code"].stringValue
    }
}

func getCodeMsg(phone: String) -> Request {
    return apiManager.request("user/getCodeMsg", body: ["phone":phone])
}

func login(phone: String, password: String) -> Request {
    return apiManager.request("user/login", body: ["phone":phone, "password":password])
}

func register(phone: String, password: String, code: String, sex: String, username: String, nickname: String) -> Request{
    return apiManager.request("user/register", body: ["phone":phone, "password":password, "code":code, "sex":sex, "username":username, "nickname":nickname])
}