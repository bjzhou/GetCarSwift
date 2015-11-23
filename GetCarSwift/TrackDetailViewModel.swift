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
    var trackTitle = ""
    var raceTrack: RmRaceTrack?

    var rx_comments: Variable<Array<Comment>> = Variable([])

    init() {
    }

    func getComments() {
        Comments.getComments(sid: sid, limit: 999)
            .filter { $0.data != nil }
            .subscribeNext { cs in
                let comments = cs.data!
               self.rx_comments.value = comments.comments
            }.addDisposableTo(disposeBag)
    }

    func postComment(text: String) -> Observable<Void> {
        return Comment.pubComment(sid: sid, content: text).map { gkResult in
            guard let str = gkResult.data else {
                self.viewProxy?.showToast("发表评论失败！")
                return
            }
            self.rx_comments.value.append(Comment(id: str, content: text, create_time: NSDate.nowString, nickname: Me.sharedInstance.nickname ?? "", head: Me.sharedInstance.nickname ?? ""))
        }
    }
}
