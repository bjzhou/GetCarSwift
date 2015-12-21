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

    static func uploadShare(recordId: String, title: String, carId: String, carDesc: String, partDescs: [String], partImages: [UIImage]) -> Observable<GKResult<Share>> {
        var params: [String: AnyObject] = ["record_id": recordId, "title": title, "car_id": carId, "car_desc": carDesc, "count": partDescs.count]
        for i in 0..<partDescs.count {
            params["desc\(i)"] = partDescs[i]
        }
        var datas = [String:NSData]()
        for i in 0..<partImages.count {
            datas["part\(i)"] = UIImagePNGRepresentation(partImages[i])
        }
        return GaikeService.sharedInstance.upload("upload/uploadShare", parameters: params, datas: datas)
    }

    func getShareUrl() -> NSURL {
        return NSURL(string: GaikeService.domain + "upload/getShare?id=" + id)!
    }
}
