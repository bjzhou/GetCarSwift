//
//  TrackViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackViewController: UITableViewController {

    let items: [(UIImage?, String)] = [(R.image.straight_race, "直线赛道"), (R.image.tianhuangping, "安吉天荒坪"), (R.image.niaoshan, "台州鸟山"), (R.image.sanjiacun, "云南三家村"), (R.image.tianmenshan, "天门山通天大道")]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.track_item, forIndexPath: indexPath)

        let imageView = cell?.viewWithTag(301) as? UIImageView
        let titleView = cell?.viewWithTag(302) as? UILabel

        imageView?.image = items[indexPath.row].0
        titleView?.text = items[indexPath.row].1

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            showViewController(R.storyboard.carBar.straightMatch!)
        } else {
            let vc = R.storyboard.carBar.track_detail!
            var trackDetailViewModel = TrackDetailViewModel()
            switch indexPath.row {
            case 1:
                trackDetailViewModel.sid = 1
                trackDetailViewModel.images = ["tianhuangping_view1", "tianhuangping_view2", "tianhuangping_view3"]
                trackDetailViewModel.trackTitle = "安吉天荒坪"
                trackDetailViewModel.trackDetail = "天荒坪位于浙江省安吉县南端，以电站惊世与竹海浩瀚的幽谷旷坪为特色，宜登山避暑、度假野营和观光游览的山岳型风景名胜区。"
                trackDetailViewModel.trackStarString = "star3"
                //destController.trackMap =  "tianhuangping_map"
            case 2:
                trackDetailViewModel.sid = 2
                trackDetailViewModel.images = ["niaoshan_view1", "niaoshan_view2", "niaoshan_view3"]
                trackDetailViewModel.trackTitle = "台州鸟山"
                trackDetailViewModel.trackDetail = "位于浙江省台州市黄岩区的鸟山，其中百王线和平佛线是车手们熟悉的山道，不乏车友聚集。"
                trackDetailViewModel.trackStarString = "star4"
                //destController.trackMap = "niaoshan_map"
            case 3:
                trackDetailViewModel.sid = 3
                trackDetailViewModel.images = ["sanjiacun_view1", "sanjiacun_view2", "sanjiacun_view3"]
                trackDetailViewModel.trackTitle = "昆明三家村"
                trackDetailViewModel.trackDetail = "位于云南省昆明市西山区的三家村，是热爱漂移的车友的好去处。"
                trackDetailViewModel.trackStarString = "star3"
                //destController.trackMap = "sanjiacun_map"
            case 4:
                trackDetailViewModel.sid = 4
                trackDetailViewModel.images = ["tianmenshan_view1", "tianmenshan_view2", "tianmenshan_view2"]
                trackDetailViewModel.trackTitle = "天门山通天大道"
                trackDetailViewModel.trackDetail = "天门山位于湖南省张家界市永定区，被称为通天大道的盘山公路共计99弯，暗合了“天有九重，云有九霄”之意。"
                trackDetailViewModel.trackStarString = "star5"
                //destController.trackMap = "tianmenshan_map"
            default:
                break
            }
            vc.trackDetailViewModel = trackDetailViewModel
            showViewController(vc)
        }
    }
}
