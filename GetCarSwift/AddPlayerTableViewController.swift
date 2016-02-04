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
    case Track
}

class AddPlayerTableViewController: UITableViewController {

    var delegate: AddPlayerDelegate?
    var sender: UIButton?
    var sid = 0
    var needBack = false

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    let titles: [AddPlayerMode:String] = [.Menu: "添加赛车手", .Myself: "我的成绩", .Car: "我的车", .Track: "赛道"]
    let menuTitles = ["我", "好友排名", "赛道总排名", "赛道月排名", "赛道周排名"]
    let menuSubTitles = ["", "", "", "", "每周三凌晨05:00点更新"]

    var mode: AddPlayerMode = .Menu

    var localNewest: [RmScore] = []
    var localBest: [RmScore] = []
    var top: [RmScore] = []
    var cars: [CarInfo] = []
    var tracks: [RmRaceTrack] = []
    var loaded = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame.size = CGSize(width: 275, height: 380)
        addSubViews()

        updateScore()
    }

    func updateScore() {

        localBest = gRealm?.objects(RmScore).filter("mapType = \(sid)").sorted("score").map { $0 } ?? []
        localNewest = gRealm?.objects(RmScore).filter("mapType = \(sid)").sorted("createdAt", ascending: false).map { $0 } ?? []
        cars = gRealm?.objects(CarInfo).map { $0 } ?? []
        tracks = gRealm?.objects(RmRaceTrack).filter { $0.isDeveloped } ?? []

        tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if mode == .Car && cars.count == 0 {
            loaded = false
            _ = CarInfo.getUserCar().subscribeNext { res in
                guard let cars = res.dataArray else {
                    return
                }

                for i in 0..<cars.count {
                    cars[i].id = i
                }
                gRealm?.writeOptional {
                    gRealm?.add(cars)
                }
                self.updateScore()
            }
        } else if mode == .Myself && localNewest.count == 0 {
            loaded = false
            getTotalRecord()
        }

    }

    func getTotalRecord() {
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

    func getFollowRecord() {
        _ = Records.getFollowRecord(self.sid, count: 50).subscribeNext(doOnGetRecord)
    }

    func getWeekRecord() {
        _ = Records.getTimeRecord(self.sid, time: "week", count: 50).subscribeNext(doOnGetRecord)
    }
    func getMonthRecord() {
        _ = Records.getTimeRecord(self.sid, time: "month", count: 50).subscribeNext(doOnGetRecord)
    }

    func doOnGetRecord(res: GKResult<Records>) {
        self.loaded = true
        guard let data = res.data else {
            return
        }
        self.top = data.top.sort { $0.0.score < $0.1.score }
        self.indicator.stopAnimating()
        self.tableView.reloadData()
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
            return menuTitles.count
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
        case .Track:
            return tracks.count
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
                cell?.textLabel?.text = menuTitles[0]
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("menu") as? PlayerTableViewCell
                if cell == nil {
                    cell = PlayerTableViewCell(style: .Subtitle, reuseIdentifier: "menu")
                }
                cell?.textLabel?.text = menuTitles[indexPath.row]
                cell?.detailTextLabel?.text = menuSubTitles[indexPath.row]
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
            cell?.imageView?.updateAvatar(top[indexPath.row].uid, url: top[indexPath.row].headUrl, inVC: self)
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
        case .Track:
            cell = tableView.dequeueReusableCellWithIdentifier("menu") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "menu")
            }
            cell?.textLabel?.text = tracks[indexPath.row].name
        }

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if mode == .Menu {
            if indexPath.row == 0 {
                mode = .Myself
                tableView.reloadData()
                if localNewest.count == 0 {
                    loaded = false
                    getTotalRecord()
                }
            } else {
                mode = .Rank
                top = []
                tableView.reloadData()
                loaded = false
                switch indexPath.row {
                case 1:
                    getFollowRecord()
                case 2:
                    getTotalRecord()
                case 3:
                    getMonthRecord()
                case 4:
                    getWeekRecord()
                default:
                    break
                }
            }
            if !loaded {
                indicator.startAnimating()
            }
            needBack = true
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
            } else if mode == .Track {
                self.delegate?.didPlayerAdded(tracks[indexPath.row], sender: self.sender)
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
        if needBack {
            mode = .Menu
            tableView.reloadData()
            needBack = false
        } else {
            dismissPopupViewController()
        }
    }

}

protocol AddPlayerDelegate {
    func didPlayerAdded(record: AnyObject, sender: UIButton?)
}
