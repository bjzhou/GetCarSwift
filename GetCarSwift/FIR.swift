//
//  FIRApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/1.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

let FIR_APP_ID = "563089a800fc7478b600000f"
let FIR_USER_TOKEN = "c5be852abca28607167f36f029ccfc1b"
let FIR_URL_VERSION_CHECK = "http://api.fir.im/apps/latest/" + FIR_APP_ID

struct FIR: JSONable {
    var name: String = ""
    var version: String = ""
    var versionShort: String = ""
    var changelog: String = ""
    var updateUrl: String = "http://fir.im/GetCar"

    init(json: JSON) {
        name = json["name"].stringValue
        version = json["version"].stringValue
        versionShort = json["versionShort"].stringValue
        changelog = json["changelog"].stringValue
        updateUrl = json["update_url"].stringValue
    }

    static func checkUpdate() -> Observable<FIR> {
        return create { observer in
            let request = apiManager.request(.GET, FIR_URL_VERSION_CHECK).responseData { res in
                if let err = res.result.error {
                    observer.on(.Error(err))
                } else {
                    if let data = res.result.value {
                        let fir = FIR(json: JSON(data: data))
                        observer.on(Event.Next(fir))
                        observer.on(Event.Completed)
                    }
                }
            }
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
}