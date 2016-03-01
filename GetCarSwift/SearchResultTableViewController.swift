//
//  SearchResultTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/4.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import UIKit

class SearchResultTableViewController: UITableViewController {

    var sender: FriendsTableViewController?
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.search, forIndexPath: indexPath)
        let user = users[indexPath.row]
        cell?.headerImageView.kf_setImageWithURL(NSURL(string: user.img)!, placeholderImage: R.image.avatar)
        cell?.sexImageView.image = user.sex == 1 ? R.image.mine_male : R.image.mine_female
        cell?.nicknameLabel.text = user.nickname
        cell?.descLabel.text = user.phone
        cell?.id = user.id
        cell?.followButton.selected = (user.friendStatus == 0 || user.friendStatus == 1)
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        let chat = ConversationViewController()
        chat.conversationType = RCConversationType.ConversationType_PRIVATE
        chat.targetId = user.id
        chat.title = user.nickname
        chat.fromSearch = true
        sender?.showViewController(chat)
    }

}
