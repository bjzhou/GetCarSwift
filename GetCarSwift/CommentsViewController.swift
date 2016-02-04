//
//  CommentsViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/17.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentTableView: UITableView!

    @IBOutlet weak var emptyView: UIView!

    var trackDetailViewModel: TrackDetailViewModel?
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = UITableViewAutomaticDimension
        commentTableView.estimatedRowHeight = 72

        initCommentsData()
    }

    func initCommentsData() {
        trackDetailViewModel?.rxComments.asObservable().subscribeNext { comments in
            self.commentTableView.reloadData()
            if comments.count == 0 {
                self.commentTableView.hidden = true
                self.emptyView.hidden = false
            } else if self.commentTableView.hidden {
                self.commentTableView.hidden = false
                self.emptyView.hidden = true
            }
            }.addDisposableTo(disposeBag)
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackDetailViewModel?.rxComments.value.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath)
        let avatarView = cell.viewWithTag(310) as? UIImageView
        let nickname = cell.viewWithTag(311) as? UILabel
        let time = cell.viewWithTag(312) as? UILabel
        let content = cell.viewWithTag(313) as? UILabel

        let comment = trackDetailViewModel?.rxComments.value[indexPath.row]

        avatarView?.updateAvatar(comment?.uid ?? "", url: comment?.head ?? "", inVC: self)

        nickname?.text = comment?.nickname
        time?.text = comment?.createTime
        content?.text = comment?.content
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
