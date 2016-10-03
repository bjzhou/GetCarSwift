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

    var indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

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

        localBest = gRealm?.objects(RmScore.self).filter("mapType = \(sid)").sorted(byProperty: "score").map { $0 } ?? []
        localNewest = gRealm?.objects(RmScore.self).filter("mapType = \(sid)").sorted(byProperty: "createdAt", ascending: false).map { $0 } ?? []
        cars = gRealm?.objects(CarInfo.self).map { $0 } ?? []
        tracks = gRealm?.objects(RmRaceTrack.self).filter { $0.isDeveloped } ?? []

        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if mode == .Car && cars.count == 0 {
            loaded = false
            _ = CarInfo.getUserCar().subscribe(onNext: { res in
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
            })
        } else if mode == .Myself && localNewest.count == 0 {
            loaded = false
            getTotalRecord()
        }

    }

    func getTotalRecord() {
        _ = Records.getRecord(self.sid, count: 50).subscribe(onNext: { res in
            self.loaded = true
            guard let data = res.data else {
                return
            }
            self.top = data.top
            self.top.sort { $0.score < $1.score }
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
        })
    }

    func getFollowRecord() {
        _ = Records.getFollowRecord(self.sid, count: 50).subscribe(onNext: doOnGetRecord)
    }

    func getWeekRecord() {
        _ = Records.getTimeRecord(self.sid, time: "week", count: 50).subscribe(onNext: doOnGetRecord)
    }
    func getMonthRecord() {
        _ = Records.getTimeRecord(self.sid, time: "month", count: 50).subscribe(onNext: doOnGetRecord)
    }

    func doOnGetRecord(_ res: GKResult<Records>) {
        self.loaded = true
        guard let data = res.data else {
            return
        }
        self.top = data.top.sorted { $0.0.score < $0.1.score }
        self.indicator.stopAnimating()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if mode == .Myself {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PlayerTableViewCell?
        switch mode {
        case .Menu:
            if (indexPath as NSIndexPath).row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "menu_me") as? PlayerTableViewCell
                if cell == nil {
                    cell = PlayerTableViewCell(style: .default, reuseIdentifier: "menu_me")
                }
                Mine.sharedInstance.setAvatarImage(cell!.imageView!)
                cell?.textLabel?.text = menuTitles[0]
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "menu") as? PlayerTableViewCell
                if cell == nil {
                    cell = PlayerTableViewCell(style: .subtitle, reuseIdentifier: "menu")
                }
                cell?.textLabel?.text = menuTitles[(indexPath as NSIndexPath).row]
                cell?.detailTextLabel?.text = menuSubTitles[(indexPath as NSIndexPath).row]
            }
        case .Myself:
            cell = tableView.dequeueReusableCell(withIdentifier: "menu") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .default, reuseIdentifier: "menu")
            }
            if (indexPath as NSIndexPath).section == 0 {
                cell?.textLabel?.text = String(format: "%.2f", localNewest[(indexPath as NSIndexPath).row].score)
            } else {
                cell?.textLabel?.text = String(format: "%.2f", localBest[(indexPath as NSIndexPath).row].score)
            }
        case .Rank:
            cell = tableView.dequeueReusableCell(withIdentifier: "player") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .subtitle, reuseIdentifier: "player")
            }
            cell?.imageView?.updateAvatar(top[indexPath.row].uid, url: top[indexPath.row].headUrl, inVC: self)
            cell?.textLabel?.text = top[(indexPath as NSIndexPath).row].nickname
            cell?.detailTextLabel?.text = String(format: "%.2f", top[(indexPath as NSIndexPath).row].score)

            cell?.medalImageView.isHidden = false
            if (indexPath as NSIndexPath).row == 0 {
                cell?.medalImageView.image = R.image.gold_medal()
            } else if (indexPath as NSIndexPath).row == 1 {
                cell?.medalImageView.image = R.image.silver_medal()
            } else if (indexPath as NSIndexPath).row == 2 {
                cell?.medalImageView.image = R.image.bronze_medal()
            } else {
                cell?.medalImageView.isHidden = true
            }
        case .Car:
            cell = tableView.dequeueReusableCell(withIdentifier: "menu") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .default, reuseIdentifier: "menu")
            }
            cell?.textLabel?.text = cars[(indexPath as NSIndexPath).row].model
        case .Track:
            cell = tableView.dequeueReusableCell(withIdentifier: "menu") as? PlayerTableViewCell
            if cell == nil {
                cell = PlayerTableViewCell(style: .default, reuseIdentifier: "menu")
            }
            cell?.textLabel?.text = tracks[(indexPath as NSIndexPath).row].name
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode == .Menu {
            if (indexPath as NSIndexPath).row == 0 {
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
                switch (indexPath as NSIndexPath).row {
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
                if (indexPath as NSIndexPath).section == 0 {
                    if localNewest[(indexPath as NSIndexPath).row].data.count > 0 {
                        self.delegate?.didPlayerAdded(localNewest[(indexPath as NSIndexPath).row], sender: self.sender)
                    } else {
                        localNewest[(indexPath as NSIndexPath).row].unarchive { record in
                            self.delegate?.didPlayerAdded(record, sender: self.sender)
                        }
                    }
                } else {
                    if localBest[(indexPath as NSIndexPath).row].data.count > 0 {
                        self.delegate?.didPlayerAdded(localBest[(indexPath as NSIndexPath).row], sender: self.sender)
                    } else {
                        localBest[(indexPath as NSIndexPath).row].unarchive { record in
                            self.delegate?.didPlayerAdded(record, sender: self.sender)
                        }
                    }
                }
            } else if mode == .Rank {
                top[(indexPath as NSIndexPath).row].unarchive { record in
                    self.delegate?.didPlayerAdded(record, sender: self.sender)
                }
            } else if mode == .Car {
                self.delegate?.didPlayerAdded(cars[(indexPath as NSIndexPath).row], sender: self.sender)
            } else if mode == .Track {
                self.delegate?.didPlayerAdded(tracks[(indexPath as NSIndexPath).row], sender: self.sender)
            }
            dismissPopupViewController()
        }
    }

    func addSubViews() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 48))
        view.backgroundColor = UIColor.white
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(R.image.backbutton(), for: UIControlState())
        button.addTarget(self, action: #selector(AddPlayerTableViewController.didBackAction), for: .touchUpInside)
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = titles[mode]
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = self.tableView.separatorColor
        view.addSubview(button)
        view.addSubview(title)
        view.addSubview(line)

        view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 8))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: title, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))

        tableView.tableHeaderView = view

        indicator.hidesWhenStopped = true
        self.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if mode == .Myself {
            if section == 0 {
                return "最新"
            } else {
                return "最佳"
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    func didPlayerAdded(_ record: AnyObject, sender: UIButton?)
}
