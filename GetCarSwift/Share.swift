//
//  Share.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/21.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct Share: JSONable {
    var id = ""
    var title = ""
    var desc = ""

    init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        desc = json["desc"].stringValue
    }

    init() {}

    static func uploadShare(sibaim: String, liushikm: String? = nil, yibaikm: String? = nil, maxa: String, maxv: String, title: String, userCarId: Int, carDesc: String) -> Observable<GKResult<Share>> {
        if let liushikm = liushikm, yibaikm = yibaikm {
            return GaikeService.sharedInstance.api("upload/uploadShare", body: ["sibaim": sibaim, "liushikm": liushikm, "yibaikm": yibaikm, "maxa": maxa, "maxv": maxv, "title": title, "user_car_id": userCarId])
        } else {
            return GaikeService.sharedInstance.api("upload/uploadShare", body: ["sibaim": sibaim, "maxa": maxa, "maxv": maxv, "title": title, "user_car_id": userCarId])
        }
    }

    static func getShareTitle() -> Observable<GKResult<Share>> {
        return GaikeService.sharedInstance.api("upload/getShareTitle")
    }

    func getShareUrl() -> NSURL {
        return NSURL(string: GaikeService.domain + "upload/getShare?id=" + id)!
    }
}
