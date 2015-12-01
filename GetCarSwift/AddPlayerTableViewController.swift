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
}

class AddPlayerTableViewController: UITableViewController {

    var delegate: AddPlayerDelegate?
    var sender: UIButton?
    var sid = 0

    let realm = try! Realm()

    let titles: [AddPlayerMode:String] = [.Menu:"添加赛车手", .Myself:"我", .Rank:"赛道排名"]

    var mode: AddPlayerMode = .Menu
    var records: Records?

    var localNewest: [RmScore] = []
    var localBest: [RmScore] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.frame.size = CGSize(width: 275, height: 200)
        addHeader()

        updateScore()
    }

    func updateScore() {
        let filterStr: String
        if sid == 0 {
            filterStr = "type = 's400'"
        } else {
            filterStr = "mapType = \(sid)"
        }

        localBest = realm.objects(RmScore).filter(filterStr).sorted("score").map { $0 }
        localNewest = realm.objects(RmScore).filter(filterStr).sorted("createdAt", ascending: true).map { $0 }

        tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        _ = Records.getRecord(sid, count: 10).subscribeNext { res in
            if let data = res.data {
                self.records = data
                self.tableView.reloadData()
            }
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
                } else if localNewest.count == 0 {
                    if let records = records where records.newestRes.count > 0 {
                        try! realm.write {
                            for score in records.newestRes {
                                self.realm.add(score)
                            }
                        }
                        updateScore()
                        return records.newestRes.count
                    }
                }
                return localNewest.count
            } else {
                if localBest.count >= 3 {
                    return 3
                } else if localBest.count == 0 {
                    if let records = records where records.bestRes.count > 0 {
                        try! realm.write {
                            for score in records.newestRes {
                                self.realm.add(score)
                            }
                        }
                        updateScore()
                        return records.bestRes.count
                    }
                }
                return localBest.count
            }
        case .Rank:
            return records?.top.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch mode {
        case .Menu:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("player")
                if cell == nil {
                    cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "player")
                }
                Mine.sharedInstance.setAvatarImage(cell!.imageView!)
                cell?.textLabel?.text = "我"
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("menu")
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: "menu")
                }
                cell?.textLabel?.text = titles[.Rank]
            }
        case .Myself:
            cell = tableView.dequeueReusableCellWithIdentifier("menu")
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "menu")
            }
            if indexPath.section == 0 {
                cell?.textLabel?.text = "\(localNewest[indexPath.row].score)"
            } else {
                cell?.textLabel?.text = "\(localBest[indexPath.row].score)"
            }
        case .Rank:
            cell = tableView.dequeueReusableCellWithIdentifier("player")
            if cell == nil {
                cell = PlayerTableViewCell(style: .Default, reuseIdentifier: "player")
            }
            cell?.imageView?.kf_setImageWithURL(NSURL(string: records?.top[indexPath.row].headUrl ?? "http://www.baidu.com")!, placeholderImage: R.image.avatar)
            cell?.textLabel?.text = "\(records?.top[indexPath.row].score ?? 0)"
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
            } else {
                records!.top[indexPath.row].unarchive { record in
                    self.delegate?.didPlayerAdded(record, sender: self.sender)
                }
            }
            dismissPopupViewController()
        }
    }

    func addHeader() {
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
        if mode == .Menu {
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
    func didPlayerAdded(record: RmScore, sender: UIButton?)
}
