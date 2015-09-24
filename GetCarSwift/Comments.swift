//
//  Comments.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct Comments: JSONable {
    var comments: [Comment] = []
    var commentsTotal = 0
    var praises: [Praise] = []
    var praisesTotal = 0

    init(json: JSON) {
        for (_, subJson) in json["comments", "content"] {
            comments.append(Comment(json: subJson))
        }
        commentsTotal = json["comments", "total"].intValue
        for (_, subJson) in json["praises", "content"] {
            praises.append(Praise(json: subJson))
        }
        praisesTotal = json["praises", "total"].intValue
    }

    static func getComments(sid sid: Int, page: Int = 0, limit: Int = 10) -> Observable<GKResult<Comments>> {
        return GaikeService.sharedInstance.api("trace/comments", body: ["sid":sid, "page":page, "limit":limit])
    }
}