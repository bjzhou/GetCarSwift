//
//  FIRApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/1.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

let FIR_APP_ID = "552a3921ebc861d936002615"
let FIR_USER_TOKEN = "c5be852abca28607167f36f029ccfc1b"
let FIR_URL_VERSION_CHECK = "http://api.fir.im/apps/latest/" + FIR_APP_ID

struct FIR {
    var name: String
    var version: String
    var versionShort: String
    var changelog: String
    var updateUrl: String
    init(json: AnyObject) {
        let json = JSON(json)
        name = json["name"].stringValue
        version = json["version"].stringValue
        versionShort = json["versionShort"].stringValue
        changelog = json["changelog"].stringValue
        updateUrl = json["update_url"].stringValue
    }
}

func checkUpdate() -> Request {
    return apiManager.request(.GET, FIR_URL_VERSION_CHECK)
}