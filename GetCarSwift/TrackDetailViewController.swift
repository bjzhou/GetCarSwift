//
//  TrackDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackDetailViewController: UIViewController {



    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackStar: UIImageView!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var loveLabel: UILabel!
    //@IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var trackDetailLabel: UILabel!
    @IBOutlet weak var index1Button: UIButton!
    @IBOutlet weak var index2Button: UIButton!
    @IBOutlet weak var index3Button: UIButton!
    @IBOutlet weak var emptyView: UIView!

    var loveButtonSelected = false {
        didSet {
            loveButton.selected = loveButtonSelected
            if loveButtonSelected {
                loveLabel.text = "已想去"
            } else {
                updateLoveLabel()
            }
        }
    }

    var sid = 0
    var images: [String] = []
    var trackTitle = ""
    var trackDetail = ""
    var trackStarString = "star3"
    //var trackMap = ""
    var lovedCount = 1000
    var comments: [Comment] = [] {
        didSet {
            commentTableView.reloadData()
            if comments.count == 0 {
                commentTableView.hidden = true
                emptyView.hidden = false
            } else if commentTableView.hidden {
                commentTableView.hidden = false
                emptyView.hidden = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = UITableViewAutomaticDimension
        commentTableView.estimatedRowHeight = 60

        initTrackData()
    }

    func initTrackData() {
        trackLabel.text = trackTitle
        trackDetailLabel.text = trackDetail
        trackStar.image = UIImage(named: trackStarString)
        //mapImageView.image = UIImage(named: trackMap)
        Comments.getComments(sid: sid, limit: 999).subscribeNext { gkResult in
            guard let comments = gkResult.data else {
                return
            }
            for comment in comments.comments {
                self.comments.insert(Comment(id: comment.id, content: comment.content, create_time: comment.create_time, nickname: comment.nickname, head: comment.head), atIndex: 0)
            }

            let myId = NSUserDefaults.standardUserDefaults().stringForKey("id")
            for praise in comments.praises {
                if myId == praise.uid && myId != "" {
                    self.loveButtonSelected = true
                }
            }
            self.lovedCount = comments.praisesTotal
            if !self.loveButtonSelected {
                self.updateLoveLabel()
            }
        }
        
    }

    override func viewDidLayoutSubviews() {
        initScrollView()
    }

    func initScrollView() {
        imageScrollView.delegate = self
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width*CGFloat(images.count), height: imageScrollView.frame.height)
        for i in 0..<images.count {
            let imageView = UIImageView(image: UIImage(named: images[i]))
            imageView.frame = CGRect(x: imageScrollView.frame.width*CGFloat(i), y: 0, width: self.view.frame.width, height: imageScrollView.frame.height)
            imageScrollView.addSubview(imageView)
        }
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

    @IBAction func didPostComment(sender: UIButton) {
        Comment.pubComment(sid: sid, content: commentTextField.text ?? "").subscribeNext { gkResult in
            guard let str = gkResult.data else {
                self.view.makeToast(message: "发表评论失败！")
                return
            }
            self.comments.append(Comment(id: str, content: self.commentTextField.text ?? "", create_time: NSDate.nowString, nickname: DataKeeper.sharedInstance.nickname ?? "", head: DataKeeper.sharedInstance.nickname ?? ""))

            self.commentTextField.text = ""
            self.commentTableView.scrollToBottom(true)
        }
        self.view.endEditing(true)
    }

    @IBAction func didIndexChanged(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.imageScrollView.contentOffset.x = CGFloat(sender.tag) * self.imageScrollView.frame.width
        })
        updateIndexButton()
    }

    @IBAction func didLoveChanged(sender: UIButton) {
        loveButtonSelected ? lovedCount-- : lovedCount++
        loveButtonSelected = !loveButtonSelected
        if loveButtonSelected {
            Praise.praise(sid: sid).subscribeNext { gkResult in
            }
        } else {
            Praise.cancelPraise(sid: sid).subscribeNext { gkResult in
            }
        }
    }

    func updateLoveLabel() {
        if lovedCount <= 0 {
            loveLabel.text = "想去"
        } else if lovedCount >= 1000 {
            loveLabel.text = "想去(999+)"
        } else {
            loveLabel.text = "想去(\(lovedCount))"
        }
    }

    func updateIndexButton() {
        index1Button.selected = false
        index2Button.selected = false
        index3Button.selected = false

        switch (imageScrollView.contentOffset.x / imageScrollView.frame.width) {
        case 0:
            index1Button.selected = true
        case 1:
            index2Button.selected = true
        case 2:
            index3Button.selected = true
        default:
            break
        }
    }

}

extension TrackDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateIndexButton()
    }
}

extension TrackDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) 
        let avatarView = cell.viewWithTag(310) as! UIImageView
        let nickname = cell.viewWithTag(311) as! UILabel
        let time = cell.viewWithTag(312) as! UILabel
        let content = cell.viewWithTag(313) as! UILabel

        if let url = NSURL(string: comments[indexPath.row].head) {
            avatarView.hnk_setImageFromURL(url, placeholder: UIImage(named: "avatar"))
        } else {
            avatarView.image = UIImage(named: "avatar")
        }

        nickname.text = comments[indexPath.row].nickname
        time.text = comments[indexPath.row].create_time
        content.text = comments[indexPath.row].content
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
