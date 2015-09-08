//
//  TraceApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/8.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class TraceApi: GaikeApi {
    static let sharedInstance = TraceApi()
    var path = "trace/"

    func comments(sid sid: Int, page: Int = 0, limit: Int = 10, completion: GKResult -> Void) {
        api("comments", body: ["sid":sid, "page":page, "limit":limit], completion: completion)
    }

    func pubComment(sid sid: Int, content: String, pid: Int = 0, completion: GKResult -> Void) {
        api("pubComment", body: ["sid":sid, "content":content, "type":1, "pid":pid], completion: completion)
    }

    func praise(sid sid: Int, completion: GKResult -> Void) {
        api("pubComment", body: ["sid":sid, "type":0], completion: completion)
    }

    func cancelPraise(sid sid: Int, completion: GKResult -> Void) {
        api("canclePraise", body: ["sid":sid], completion: completion)
    }
}