//
//  CommentsViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/17.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentTableView: UITableView!

    @IBOutlet weak var emptyView: UIView!

    var trackDetailViewModel: TrackDetailViewModel?
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = UITableViewAutomaticDimension
        commentTableView.estimatedRowHeight = 60

        initCommentsData()
    }

    func initCommentsData() {
        trackDetailViewModel?.rx_comments.subscribeNext { comments in
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

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                UIView.animateWithDuration(0.3, animations: {
                    self.view.frame.origin = CGPoint(x: 0, y: -keyboardSize.height)
                })
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame.origin = CGPoint(x: 0, y: 0)
        })
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackDetailViewModel?.rx_comments.value.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath)
        let avatarView = cell.viewWithTag(310) as! UIImageView
        let nickname = cell.viewWithTag(311) as! UILabel
        let time = cell.viewWithTag(312) as! UILabel
        let content = cell.viewWithTag(313) as! UILabel

        if let url = NSURL(string: trackDetailViewModel?.rx_comments.value[indexPath.row].head ?? "") {
            avatarView.hnk_setImageFromURL(url, placeholder: R.image.avatar)
        } else {
            avatarView.image = R.image.avatar
        }

        nickname.text = trackDetailViewModel?.rx_comments.value[indexPath.row].nickname
        time.text = trackDetailViewModel?.rx_comments.value[indexPath.row].create_time
        content.text = trackDetailViewModel?.rx_comments.value[indexPath.row].content
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

