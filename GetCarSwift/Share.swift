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

    init(json: JSON) {
        id = json["id"].stringValue
    }

    init() {}

    static func uploadShare(sibaim: String, liushikm: String = "", yibaikm: String = "", maxa: String, maxv: String, title: String, carId: Int, carDesc: String) -> Observable<GKResult<Share>> {
        return GaikeService.sharedInstance.api("upload/uploadShare", body: ["sibaim": sibaim, "liushikm": liushikm, "yibaikm": yibaikm, "maxa": maxa, "maxv": maxv, "title": title, "car_id": carId, "car_desc": carDesc])
    }

    func getShareUrl() -> NSURL {
        return NSURL(string: GaikeService.domain + "upload/getShare?id=" + id)!
    }
}
