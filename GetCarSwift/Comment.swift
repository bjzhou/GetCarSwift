//
//  TraceApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/8.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct Comment: JSONable {
    var id: String?
    var content = ""
    var create_time = ""
    var nickname = ""
    var head = ""
    var uid = ""

    init(id: String?, content: String, create_time: String, nickname: String, head: String, uid: String) {
        self.id = id
        self.content = content
        self.create_time = create_time
        self.nickname = nickname
        self.head = head
        self.uid = uid
    }

    init(json: JSON) {
        id = json["id"].string
        content = json["content"].stringValue
        create_time = json["create_time"].stringValue
        nickname = json["nickname"].stringValue
        head = json["head"].stringValue
        uid = json["uid"].stringValue
    }

    static func pubComment(sid sid: Int, content: String, pid: Int = 0) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("trace/pubComment", body: ["sid":sid, "content":content, "type":1, "pid":pid])
    }

}
