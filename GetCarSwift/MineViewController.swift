//
//  MineViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class MineViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        if indexPath.section == 0 {
            var accountCell = cell as! AccountCell
            accountCell.avatar.layer.masksToBounds = true
            accountCell.avatar.layer.cornerRadius = 8
            accountCell.avatar.image = UIImage(contentsOfFile: getFilePath("avatar"))
            accountCell.accountName.text = "SURA"
            accountCell.accountDescription.text = "上海市浦东新区"
            return accountCell
        }
        return cell
    }

}
