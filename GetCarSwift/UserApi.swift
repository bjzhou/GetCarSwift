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
    return apiManager.request(.POST, DOMAIN + "user/getCodeMsg", body: JSON(["phone":phone]))
}