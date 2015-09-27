//
// Created by 周斌佳 on 15/9/27.
// Copyright (c) 2015 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct TrackDetailViewModel {

    var viewProxy: ViewProxy?

    var sid = 0
    var images: [String] = []
    var trackTitle = ""
    var trackDetail = ""
    var trackStarString = "star3"
    //var trackMap = ""

    var rx_comments: Variable<Array<Comment>> = Variable([])
    var rx_loveButtonSelected = Variable(false)
    var rx_lovedCount = Variable(1000)

    init() {
    }

    func getComments() {
        Comments.getComments(sid: sid, limit: 999)
            .filter { $0.data != nil }
            .subscribeNext { cs in
                let comments = cs.data!
                self.rx_lovedCount.value = comments.praisesTotal
                for praise in comments.praises {
                    if Me.sharedInstance.id == praise.uid {
                        self.rx_loveButtonSelected.value = true
                    }
                }
               self.rx_comments.value = comments.comments
            }
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

    func didLoveChanged() {
        self.rx_loveButtonSelected.value ? self.rx_lovedCount.value-- : self.rx_lovedCount.value++
        self.rx_loveButtonSelected.value = !self.rx_loveButtonSelected.value
        if self.rx_loveButtonSelected.value {
            Praise.praise(sid: sid).subscribeNext { gkResult in
            }
        } else {
            Praise.cancelPraise(sid: sid).subscribeNext { gkResult in
            }
        }
    }
}
