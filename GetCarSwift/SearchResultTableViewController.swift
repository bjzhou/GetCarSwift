//
//  SearchResultTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/4.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import UIKit

class SearchResultTableViewController: UITableViewController {

    var searchResultCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.search, forIndexPath: indexPath)

        cell?.headerImageView.image = R.image.avatar
        cell?.sexImageView.image = R.image.mine_male
        cell?.nicknameLabel.text = "用户名"
        cell?.descLabel.text = "好友简介"
        return cell!
    }

}
