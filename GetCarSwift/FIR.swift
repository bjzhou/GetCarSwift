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

let firAppId = "563089a800fc7478b600000f"
let firUserToken = "c5be852abca28607167f36f029ccfc1b"
let firVersionCheckUrl = "http://api.fir.im/apps/latest/\(firAppId)?api_token=\(firUserToken)"

struct FIR: JSONable {
    var name: String = ""
    var version: Int = 0
    var versionShort: String = ""
    var changelog: String = ""
    var updateUrl = "http://fir.im/GetCar"

    init(json: JSON) {
        name = json["name"].stringValue
        version = json["version"].intValue
        versionShort = json["versionShort"].stringValue
        changelog = json["changelog"].stringValue
        updateUrl = json["update_url"].stringValue
    }

    static func checkUpdate() -> Observable<FIR> {
        return Observable.create { observer in
            let request = apiManager.request(firVersionCheckUrl).responseData { res in
                if let err = res.result.error {
                    observer.on(.error(err))
                } else {
                    if let data = res.result.value {
                        let fir = FIR(json: JSON(data: data))
                        observer.on(Event.next(fir))
                        observer.on(Event.completed)
                    }
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
