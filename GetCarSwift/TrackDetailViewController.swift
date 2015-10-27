//
//  TrackDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class TrackDetailViewController: UIViewController {

    let disposeBag = DisposeBag()

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

    var trackDetailViewModel: TrackDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = UITableViewAutomaticDimension
        commentTableView.estimatedRowHeight = 60

        trackDetailViewModel.viewProxy = self
        initTrackData()
    }

    func initTrackData() {
        trackLabel.text = trackDetailViewModel.trackTitle
        trackDetailLabel.text = trackDetailViewModel.trackDetail
        trackStar.image = UIImage(named: trackDetailViewModel.trackStarString)
        //mapImageView.image = UIImage(named: trackDetailViewModel.trackMap)
        trackDetailViewModel.getComments()

        combineLatest(trackDetailViewModel.rx_loveButtonSelected, trackDetailViewModel.rx_lovedCount) { selected, lovedCount in
            return (selected, lovedCount)
            }.subscribeNext { selected, lovedCount in
                if selected {
                    self.loveLabel.text = "已想去"
                    return
                }
                if lovedCount <= 0 {
                    self.loveLabel.text = "想去"
                } else if lovedCount >= 1000 {
                    self.loveLabel.text = "想去(999+)"
                } else {
                    self.loveLabel.text = "想去(\(lovedCount))"
                }
        }.addDisposableTo(disposeBag)

        trackDetailViewModel.rx_loveButtonSelected.bindTo(loveButton.rx_selected).addDisposableTo(disposeBag)

        trackDetailViewModel.rx_comments.subscribeNext { comments in
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

    override func viewDidLayoutSubviews() {
        initScrollView()
    }

    func initScrollView() {
        imageScrollView.delegate = self
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width*CGFloat(trackDetailViewModel.images.count), height: imageScrollView.frame.height)
        for i in 0..<trackDetailViewModel.images.count {
            let imageView = UIImageView(image: UIImage(named: trackDetailViewModel.images[i]))
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
        trackDetailViewModel.postComment(commentTextField.text ?? "").subscribeNext {
            self.commentTextField.text = ""
            self.commentTableView.scrollToBottom(true)
        }.addDisposableTo(disposeBag)
        self.view.endEditing(true)
    }

    @IBAction func didIndexChanged(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.imageScrollView.contentOffset.x = CGFloat(sender.tag) * self.imageScrollView.frame.width
        })
        updateIndexButton()
    }

    @IBAction func didLoveChanged(sender: UIButton) {
        trackDetailViewModel.didLoveChanged()
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
        return trackDetailViewModel.rx_comments.value.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) 
        let avatarView = cell.viewWithTag(310) as! UIImageView
        let nickname = cell.viewWithTag(311) as! UILabel
        let time = cell.viewWithTag(312) as! UILabel
        let content = cell.viewWithTag(313) as! UILabel

        if let url = NSURL(string: trackDetailViewModel.rx_comments.value[indexPath.row].head) {
            avatarView.hnk_setImageFromURL(url, placeholder: UIImage(named: "avatar"))
        } else {
            avatarView.image = UIImage(named: "avatar")
        }

        nickname.text = trackDetailViewModel.rx_comments.value[indexPath.row].nickname
        time.text = trackDetailViewModel.rx_comments.value[indexPath.row].create_time
        content.text = trackDetailViewModel.rx_comments.value[indexPath.row].content
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
