//
//  TraceApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/8.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class TraceApi: GaikeService {
    static let sharedInstance = TraceApi()

    override func path() -> String {
        return "trace/"
    }

    func comments(#sid: Int, page: Int = 0, limit: Int = 10, completion: GKResult -> Void) {
        api("comments", body: ["sid":sid, "page":page, "limit":limit], completion: completion)
    }

    func pubComment(#sid: Int, content: String, pid: Int = 0, completion: GKResult -> Void) {
        api("pubComment", body: ["sid":sid, "content":content, "type":1, "pid":pid], completion: completion)
    }

    func praise(#sid: Int, completion: GKResult -> Void) {
        api("pubComment", body: ["sid":sid, "type":0], completion: completion)
    }

    func cancelPraise(#sid: Int, completion: GKResult -> Void) {
        api("canclePraise", body: ["sid":sid], completion: completion)
    }
}