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
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        searchResultController = R.storyboard.friend.friend_search()
        searchResultController.sender = self

        searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar

        searchController.delegate = self
        searchController.searchBar.delegate = self    // so we can monitor text changes + others

        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getFriend()
    }

    func getFriend() {
        _ = User.getFriend().subscribe(onNext: { res in
            guard let users = res.dataArray else {
                return
            }
            self.users = users
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.friend, for: indexPath)

        let user = users[(indexPath as NSIndexPath).row]
        cell?.headerImageView.kf.setImage(with: URL(string: user.img)!, placeholder: R.image.avatar())
        cell?.sexImageView.image = user.sex == 1 ? R.image.mine_male() : R.image.mine_female()
        cell?.nicknameLabel.text = user.nickname
        cell?.descLabel.text = user.phone
        cell?.id = user.id
        cell?.followButton.isSelected = (user.friendStatus == 0 || user.friendStatus == 1)

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[(indexPath as NSIndexPath).row]
        showConversationView(user)
    }

    func showConversationView(_ user: User) {
        let chat = ConversationViewController()
        chat.conversationType = RCConversationType.ConversationType_PRIVATE
        chat.targetId = user.id
        chat.title = user.nickname
        showViewController(chat)
    }

}

extension FriendsTableViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.trim() != "" {
            _ = User.searchUser(searchController.searchBar.text!).subscribe(onNext: { res in
                guard let users = res.dataArray else {
                    return
                }
                self.searchResultController.users = users
                self.searchResultController.tableView.reloadData()
            })
        } else {
            self.searchResultController.users = []
            self.searchResultController.tableView.reloadData()
        }
    }

    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
        getFriend()
    }
}
