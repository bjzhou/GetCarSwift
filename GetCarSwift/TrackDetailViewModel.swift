//
// Created by 周斌佳 on 15/9/27.
// Copyright (c) 2015 周斌佳. All rights reserved.
//

import Foundation
import RxSwift

struct TrackDetailViewModel {

    let disposeBag = DisposeBag()

    var viewProxy: ViewProxy?

    var sid = 0
    var raceTrack: RmRaceTrack?

    var rxComments: Variable<Array<Comment>> = Variable([])

    init() {
    }

    func getComments() -> Observable<Array<Comment>> {
        return Comments.getComments(sid: sid, limit: 999)
            .filter { $0.data != nil }
            .map { cs in
                let comments = cs.data!
               self.rxComments.value = comments.comments
                return self.rxComments.value
            }
    }

    func postComment(_ text: String) -> Observable<Void> {
        return Comment.pubComment(sid: sid, content: text).map { gkResult in
            guard let str = gkResult.data else {
                self.viewProxy?.showToast("发表评论失败！")
                return
            }
            self.rxComments.value.insert(Comment(id: str, content: text, createTime: Date.nowString, nickname: Mine.sharedInstance.nickname, head: Mine.sharedInstance.avatarUrl, uid: Mine.sharedInstance.id), at: 0)
        }
    }
}
