//
//  FriendsTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/4.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    var searchController: UISearchController!
    var searchResultController: SearchResultTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchResultController = R.storyboard.friend.friend_search

        searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar

        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others

        definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.friend, forIndexPath: indexPath)

        cell?.headerImageView.image = R.image.avatar
        cell?.sexImageView.image = R.image.mine_male
        cell?.nicknameLabel.text = "用户名"
        cell?.descLabel.text = "好友简介"

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chat = ConversationViewController()
        chat.conversationType = RCConversationType.ConversationType_PRIVATE
        chat.targetId = "targetIdYouWillChatIn"
        chat.title = "想显示的会话标题"
        showViewController(chat)
    }

}

extension FriendsTableViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchResultController.searchResultCount = Int(searchController.searchBar.text!) ?? 0
        searchResultController.tableView.reloadData()
    }

    func willPresentSearchController(searchController: UISearchController) {
        self.navigationController?.navigationBar.translucent = true
    }

    func willDismissSearchController(searchController: UISearchController) {
        self.navigationController?.navigationBar.translucent = false
    }
}
