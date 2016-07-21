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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.search, for: indexPath)
        let user = users[(indexPath as NSIndexPath).row]
        cell?.headerImageView.kf_setImageWithURL(URL(string: user.img)!, placeholderImage: R.image.avatar)
        cell?.sexImageView.image = user.sex == 1 ? R.image.mine_male : R.image.mine_female
        cell?.nicknameLabel.text = user.nickname
        cell?.descLabel.text = user.phone
        cell?.id = user.id
        cell?.followButton.isSelected = (user.friendStatus == 0 || user.friendStatus == 1)
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[(indexPath as NSIndexPath).row]
        let chat = ConversationViewController()
        chat.conversationType = RCConversationType.ConversationType_PRIVATE
        chat.targetId = user.id
        chat.title = user.nickname
        chat.fromSearch = true
        sender?.showViewController(chat)
    }

}
