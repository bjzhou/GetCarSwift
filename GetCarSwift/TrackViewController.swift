//
//  TrackViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

class TrackViewController: UITableViewController {

    let realm = try! Realm()

    let items: [(UIImage?, String, UIImage?)] = [(R.image.straight_race, "直线赛道", R.image.star3), (R.image.tianhuangping, "天马赛车场", R.image.star3), (R.image.tianhuangping, "安吉天荒坪", R.image.star3), (R.image.niaoshan, "台州鸟山", R.image.star4), (R.image.sanjiacun, "云南三家村", R.image.star3), (R.image.tianmenshan, "天门山通天大道", R.image.star5)]

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.track_item, forIndexPath: indexPath)

        cell!.trackBg.image = items[indexPath.row].0
        cell!.trackLabel.text = items[indexPath.row].1
        cell!.trackStar.image = items[indexPath.row].2
        cell!.lovedCount = 1000
        cell!.hideStar = indexPath.row == 0

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            showViewController(R.storyboard.track.straightMatch!)
        } else {
            let vc = R.storyboard.track.track_detail
            var trackDetailViewModel = TrackDetailViewModel()
            switch indexPath.row {
            case 1:
                trackDetailViewModel.sid = 5
                trackDetailViewModel.trackTitle = "天马赛车场"
                trackDetailViewModel.raceTrack = realm.objects(RmRaceTrack).filter("name = 'tianma'").first
            case 2:
                trackDetailViewModel.sid = 1
                trackDetailViewModel.trackTitle = "安吉天荒坪"
                trackDetailViewModel.raceTrack = realm.objects(RmRaceTrack).filter("name = 'anji'").first
            case 3:
                trackDetailViewModel.sid = 2
                trackDetailViewModel.trackTitle = "台州鸟山"
            case 4:
                trackDetailViewModel.sid = 3
                trackDetailViewModel.trackTitle = "昆明三家村"
            case 5:
                trackDetailViewModel.sid = 4
                trackDetailViewModel.trackTitle = "天门山通天大道"
            default:
                break
            }
            vc?.trackDetailViewModel = trackDetailViewModel
            showViewController(vc!)
        }
    }
}
