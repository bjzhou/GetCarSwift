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
    var createTime = ""
    var nickname = ""
    var head = ""
    var uid = ""

    init(id: String?, content: String, createTime: String, nickname: String, head: String, uid: String) {
        self.id = id
        self.content = content
        self.createTime = createTime
        self.nickname = nickname
        self.head = head
        self.uid = uid
    }

    init(json: JSON) {
        id = json["id"].string
        content = json["content"].stringValue
        createTime = json["create_time"].stringValue
        nickname = json["nickname"].stringValue
        head = json["head"].stringValue
        uid = json["uid"].stringValue
    }

    static func pubComment(sid: Int, content: String, pid: Int = 0) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("trace/pubComment", body: ["sid":sid, "content":content, "type":1, "pid":pid])
    }

}
