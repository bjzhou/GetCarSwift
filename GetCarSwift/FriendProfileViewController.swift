//
//  FriendProfileViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/22.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class FriendProfileViewController: UIViewController {

    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var sexImage: UIImageView!
    @IBOutlet weak var myAvatar: UIImageView!
    @IBOutlet weak var homepageBg: UIImageView!
    @IBOutlet weak var msgButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var scoreTableView: UITableView!

    var uid = ""
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = self.presentingViewController {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: "dismiss")
        }

        scoreTableView.delegate = self
        scoreTableView.dataSource = self

        _ = User.getUserInfo(uid).subscribeNext { res in
            guard let user = res.data else {
                return
            }
            self.user = user

            _ = self.msgButton.rx_tap.takeUntil(self.msgButton.rx_deallocated).subscribeNext {
                let chat = ConversationViewController()
                chat.conversationType = RCConversationType.ConversationType_PRIVATE
                chat.targetId = self.uid
                chat.title = self.user?.nickname
                chat.fromProfile = true
                self.showViewController(chat)
            }

            _ = self.followButton.rx_tap.takeUntil(self.followButton.rx_deallocated).subscribeNext {
                Toast.makeToastActivity()
                if self.followButton.currentTitle == "已关注" {
                    _ = User.removeFriend(self.uid).doOn { _ in
                        Toast.hideToastActivity()
                        }.subscribeNext { res in
                            if res.code == 0 {
                                self.followButton.setTitle("+关注", forState: .Normal)
                            }
                    }
                } else {
                    _ = User.addFriend(self.uid).doOn { _ in
                        Toast.hideToastActivity()
                        }.subscribeNext { res in
                            if res.code == 0 {
                                self.followButton.setTitle("已关注", forState: .Normal)
                            }
                    }
                }
            }
            self.sexImage.image = self.user?.sex == 1 ? R.image.mine_male : R.image.mine_female
            self.nickname.text = self.user?.nickname
            self.myAvatar.kf_setImageWithURL(NSURL(string: self.user?.img ?? "")!, placeholderImage: R.image.avatar)
            self.scoreTableView.reloadData()
        }
    }

    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension FriendProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.profile_score, forIndexPath: indexPath)
        cell?.textLabel?.text = "直线赛道"
        cell?.detailTextLabel?.text = "00:00.00"
        return cell!
    }
}
