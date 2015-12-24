//
//  AddPlayerTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/25.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

enum AddPlayerMode {
    case Menu
    case Myself
    case Rank
    case Car
}

class AddPlayerTableViewController: UITableViewController {

    var delegate: AddPlayerDelegate?
    var sender: UIButton?
    var sid = 0

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    let titles: [AddPlayerMode:String] = [.Menu: "添加赛车手", .Myself: "我的成绩", .Rank: "赛道排名", .Car: "我的车"]

    var mode: AddPlayerMode = .Menu

    var localNewest: [RmScore] = []
    var localBest: [RmScore] = []
    var top: [RmScore] = []
    var cars: [CarInfo] = []
    var loaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame.size = CGSize(width: 275, height: 200)
        addSubViews()

        updateScore()
    }

    func updateScore() {

        localBest = gRealm?.objects(RmScore).filter("mapType = \(sid)").sorted("score").map { $0 } ?? []
        localNewest = gRealm?.objects(RmScore).filter("mapType = \(sid)").sorted("createdAt", ascending: false).map { $0 } ?? []
        cars = gRealm?.objects(CarInfo).map { $0 } ?? []

        tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        loaded = false
        _ = Records.getRecord(self.sid, count: 50).subscribeNext { res in
            self.loaded = true
            guard let data = res.data else {
                return
            }
            self.top = data.top.sort { $0.0.score < $0.1.score }
            if self.localNewest.count == 0 {
                for s in data.newestRes {
                    gRealm?.writeOptional {
                        gRealm?.add(s, update: true)
                    }
                }
                for s in data.bestRes {
                    gRealm?.writeOptional {
                        gRealm?.add(s, update: true)
                    }
                }
                self.updateScore()
            }
            self.indicator.stopAnimating()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if mode == .Myself {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .Menu:
            return 2
        case .Myself:
            if section == 0 {
                if localNewest.count >= 3 {
                    return 3
                }
                return localNewest.count
            } else {
                if localBest.count >= 3 {
                    return 3
                }
                return localBest.count
            }
        case .Rank:
            return top.count
        case .Car:
            return cars.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: PlayerTableViewCell?
        switch mode {
        case .Menu:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("menu_me") as? PlayerTableViewCell
                if cell == nil {
                    cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "menu_me")
                }
                Mine.sharedInstance.setAvatarImage(cell!.imageView!)
                cell?.textLabel?.text = "我"
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("menu") as? PlayerTableViewCell
                if cell == nil {
                    cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "menu")
                }
                cell?.textLabel?.text = titles[.Rank]
            }
        case .Myself:
            cell = tableView.dequeueReusableCellWithIdentifier("menu") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "menu")
            }
            if indexPath.section == 0 {
                cell?.textLabel?.text = String(format: "%.2f", localNewest[indexPath.row].score)
            } else {
                cell?.textLabel?.text = String(format: "%.2f", localBest[indexPath.row].score)
            }
        case .Rank:
            cell = tableView.dequeueReusableCellWithIdentifier("player") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .Subtitle, reuseIdentifier: "player")
            }
            cell?.imageView?.updateAvatar(top[indexPath.row].uid, url: top[indexPath.row].headUrl, nickname: top[indexPath.row].nickname, inVC: self)
            cell?.textLabel?.text = top[indexPath.row].nickname
            cell?.detailTextLabel?.text = String(format: "%.2f", top[indexPath.row].score)

            cell?.medalImageView.hidden = false
            if indexPath.row == 0 {
                cell?.medalImageView.image = R.image.gold_medal
            } else if indexPath.row == 1 {
                cell?.medalImageView.image = R.image.silver_medal
            } else if indexPath.row == 2 {
                cell?.medalImageView.image = R.image.bronze_medal
            } else {
                cell?.medalImageView.hidden = true
            }
        case .Car:
            cell = tableView.dequeueReusableCellWithIdentifier("menu") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "menu")
            }
            cell?.textLabel?.text = cars[indexPath.row].model
        }

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if mode == .Menu {
            if indexPath.row == 0 {
                mode = .Myself
                tableView.reloadData()
            } else if indexPath.row == 1 {
                mode = .Rank
                tableView.reloadData()
            }
            self.view.frame.size = CGSize(width: 275, height: 380)
            self.view.center = self.view.superview!.center
            if !loaded {
                indicator.startAnimating()
            }
        } else {
            if mode == .Myself {
                if indexPath.section == 0 {
                    if localNewest[indexPath.row].data.count > 0 {
                        self.delegate?.didPlayerAdded(localNewest[indexPath.row], sender: self.sender)
                    } else {
                        localNewest[indexPath.row].unarchive { record in
                            self.delegate?.didPlayerAdded(record, sender: self.sender)
                        }
                    }
                } else {
                    if localBest[indexPath.row].data.count > 0 {
                        self.delegate?.didPlayerAdded(localBest[indexPath.row], sender: self.sender)
                    } else {
                        localBest[indexPath.row].unarchive { record in
                            self.delegate?.didPlayerAdded(record, sender: self.sender)
                        }
                    }
                }
            } else if mode == .Rank {
                top[indexPath.row].unarchive { record in
                    self.delegate?.didPlayerAdded(record, sender: self.sender)
                }
            } else if mode == .Car {
                self.delegate?.didPlayerAdded(cars[indexPath.row], sender: self.sender)
            }
            dismissPopupViewController()
        }
    }

    func addSubViews() {
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

        tableView.tableHeaderView = view

        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if mode == .Myself {
            if section == 0 {
                return "最新"
            } else {
                return "最佳"
            }
        }
        return nil
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func didBackAction() {
        if mode == .Menu || mode == .Car {
            dismissPopupViewController()
        } else {
            mode = .Menu
            tableView.reloadData()
            self.view.frame.size = CGSize(width: 275, height: 200)
            self.view.center = self.view.superview!.center
        }
    }

}

protocol AddPlayerDelegate {
    func didPlayerAdded(record: AnyObject, sender: UIButton?)
}
