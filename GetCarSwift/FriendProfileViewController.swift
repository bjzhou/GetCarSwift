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
    var sex = 0
    var nicknameText = ""
    var avatarUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = self.presentingViewController {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: "dismiss")
        }

        scoreTableView.delegate = self
        scoreTableView.dataSource = self

        _ = msgButton.rx_tap.takeUntil(msgButton.rx_deallocated).subscribeNext {
            let chat = ConversationViewController()
            chat.conversationType = RCConversationType.ConversationType_PRIVATE
            chat.targetId = self.uid
            chat.title = self.nicknameText
            chat.fromProfile = true
            self.showViewController(chat)
        }

        _ = followButton.rx_tap.takeUntil(followButton.rx_deallocated).subscribeNext {
            if self.followButton.currentTitle == "已关注" {
                return
            }
            _ = User.addFriend(self.uid).subscribeNext { res in
                if res.code == 0 {
                    self.followButton.setTitle("已关注", forState: .Normal)
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        sexImage.image = sex == 1 ? R.image.mine_male : R.image.mine_female
        nickname.text = nicknameText
        myAvatar.kf_setImageWithURL(NSURL(string: avatarUrl)!, placeholderImage: sex == 1 ? R.image.avatar : R.image.avatar_female)
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
