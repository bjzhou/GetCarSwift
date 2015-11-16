//
//  AddPlayerTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/25.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import Haneke
import RealmSwift

enum AddPlayerMode {
    case Menu
    case Friend
    case Rank
}

class AddPlayerTableViewController: UITableViewController {

    var delegate: AddPlayerDelegate?
    var sender: UIButton?
    var type: String = "anji"

    let realm = try! Realm()

    let titles: [AddPlayerMode:String] = [.Menu:"添加赛车手", .Friend:"我的好友", .Rank:"赛道排名"]

    var mode: AddPlayerMode = .Menu
    var friends = ["aaaaaaaaaaaaaaa", "bbb", "ccc", "ddd", "eee", "fff"]
    var rankings = [RmScore]()

    override func viewDidLoad() {
        super.viewDidLoad()

        rankings = realm.objects(RmScore).filter("type = '\(type)'").map { $0 }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .Menu:
            return 3
        case .Friend:
            return friends.count
        case .Rank:
            return rankings.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        switch mode {
        case .Menu:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) 
                let avatarView = cell.viewWithTag(111) as! UIImageView
                avatarView.setAvatarImage()
                let nameLabel = cell.viewWithTag(112) as! UILabel
                nameLabel.text = "我"
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("menu", forIndexPath: indexPath) 
                cell.textLabel?.text = indexPath.row == 1 ? titles[.Friend] : titles[.Rank]
            }
        case .Friend:
            cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) 
            let avatarView = cell.viewWithTag(111) as! UIImageView
            avatarView.image = R.image.avatar
            let nameLabel = cell.viewWithTag(112) as! UILabel
            nameLabel.text = friends[indexPath.row]
        case .Rank:
            cell = tableView.dequeueReusableCellWithIdentifier("rank", forIndexPath: indexPath) 
            let avatarView = cell.viewWithTag(122) as! UIImageView
            avatarView.image = R.image.avatar
            let rankLabel = cell.viewWithTag(121) as! UILabel
            rankLabel.text = String(indexPath.row+1)
            let nameLabel = cell.viewWithTag(123) as! UILabel
            nameLabel.text = rankings[indexPath.row].name
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if mode == .Menu {
            if indexPath.row == 1 {
                mode = .Friend
                tableView.reloadData()
            } else if indexPath.row == 2 {
                mode = .Rank
                tableView.reloadData()
            } else {
                Me.sharedInstance.fetchAvatar { image in
                    self.delegate?.didPlayerAdded(avatar: image, name: "我", score: RmScore(), sender: self.sender)
                    self.dismissPopupViewController()
                }
            }
            if indexPath.row != 0 {
                self.view.frame.size = CGSize(width: 275, height: 380)
                self.view.center = self.view.superview!.center
            }
        } else {
            delegate?.didPlayerAdded(avatar: R.image.avatar!, name: mode == .Friend ? friends[indexPath.row] : rankings[indexPath.row].name, score: rankings[indexPath.row], sender: sender)
            dismissPopupViewController()
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 48))
        view.backgroundColor = UIColor.whiteColor()
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(R.image.backbutton, forState: .Normal)
        button.addTarget(self, action: Selector("didBackAction"), forControlEvents: .TouchUpInside)
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = titles[mode]
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = self.tableView.separatorColor
        view.addSubview(button)
        view.addSubview(title)
        view.addSubview(line)

        view.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 8))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: title, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0.5))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))

        return view
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func didBackAction() {
        if mode == .Menu {
            dismissPopupViewController()
        } else {
            mode = .Menu
            tableView.reloadData()
            self.view.frame.size = CGSize(width: 275, height: 258)
            self.view.center = self.view.superview!.center
        }
    }

}

protocol AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String, score: RmScore, sender: UIButton?)
}
