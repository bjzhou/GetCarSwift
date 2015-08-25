//
//  AddPlayerTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/25.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

enum AddPlayerMode {
    case Menu
    case Friend
    case Rank
}

class AddPlayerTableViewController: UITableViewController {

    let titles: [AddPlayerMode:String] = [.Menu:"添加赛车手", .Friend:"我的好友", .Rank:"赛道排名"]

    var mode: AddPlayerMode = .Menu
    var friends = ["aaa", "bbb", "ccc", "ddd", "eee", "fff"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .Menu:
            return 4
        case .Friend:
            return friends.count + 1
        case .Rank:
            return 6
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("title", forIndexPath: indexPath)
            let titleLabel = cell.viewWithTag(101) as! UILabel
            titleLabel.text = titles[mode]
        } else {
            switch mode {
            case .Menu:
                if indexPath.row == 1 {
                    cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath)
                    let avatarView = cell.viewWithTag(111) as! UIImageView
                    avatarView.image = avatarImage()
                    let nameLabel = cell.viewWithTag(112) as! UILabel
                    nameLabel.text = "我"
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier("menu", forIndexPath: indexPath)
                    cell.textLabel?.text = indexPath.row == 2 ? titles[.Friend] : titles[.Rank]
                }
            case .Friend:
                cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath)
                //let avatarView = cell.viewWithTag(111) as! UIImageView
                //avatarView.image = ...
                let nameLabel = cell.viewWithTag(112) as! UILabel
                nameLabel.text = friends[indexPath.row-1]
            case .Rank:
                cell = tableView.dequeueReusableCellWithIdentifier("rank", forIndexPath: indexPath)
                //let avatarView = cell.viewWithTag(111) as! UIImageView
                //avatarView.image = ...
                let rankLabel = cell.viewWithTag(121) as! UILabel
                rankLabel.text = String(indexPath.row)
                let nameLabel = cell.viewWithTag(123) as! UILabel
                nameLabel.text = "排名第\(indexPath.row)"
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
            if mode == .Menu {
                if indexPath.row == 2 {
                    mode = .Friend
                    tableView.reloadData()
                } else if indexPath.row == 3 {
                    mode = .Rank
                    tableView.reloadData()
                }
            } else {
                // selected item, dismiss view
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        } else {
            return 60
        }
    }

    @IBAction func didBackAction() {
        if mode == .Menu {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            mode = .Menu
            tableView.reloadData()
        }
    }

}
