//
//  TrackViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destController = segue.destinationViewController as! TrackDetailViewController
        var trackDetailViewModel = TrackDetailViewModel()
        switch segue.identifier {
        case .Some("tianhuangping"):
            trackDetailViewModel.sid = 1
            trackDetailViewModel.images = ["tianhuangping_view1", "tianhuangping_view2", "tianhuangping_view3"]
            trackDetailViewModel.trackTitle = "安吉天荒坪"
            trackDetailViewModel.trackDetail = "天荒坪位于浙江省安吉县南端，以电站惊世与竹海浩瀚的幽谷旷坪为特色，宜登山避暑、度假野营和观光游览的山岳型风景名胜区。"
            trackDetailViewModel.trackStarString = "star3"
            //destController.trackMap =  "tianhuangping_map"
        case .Some("niaoshan"):
            trackDetailViewModel.sid = 2
            trackDetailViewModel.images = ["niaoshan_view1", "niaoshan_view2", "niaoshan_view3"]
            trackDetailViewModel.trackTitle = "台州鸟山"
            trackDetailViewModel.trackDetail = "位于浙江省台州市黄岩区的鸟山，其中百王线和平佛线是车手们熟悉的山道，不乏车友聚集。"
            trackDetailViewModel.trackStarString = "star4"
            //destController.trackMap = "niaoshan_map"
        case .Some("sanjiacun"):
            trackDetailViewModel.sid = 3
            trackDetailViewModel.images = ["sanjiacun_view1", "sanjiacun_view2", "sanjiacun_view3"]
            trackDetailViewModel.trackTitle = "昆明三家村"
            trackDetailViewModel.trackDetail = "位于云南省昆明市西山区的三家村，是热爱漂移的车友的好去处。"
            trackDetailViewModel.trackStarString = "star3"
            //destController.trackMap = "sanjiacun_map"
        case .Some("tianmenshan"):
            trackDetailViewModel.sid = 4
            trackDetailViewModel.images = ["tianmenshan_view1", "tianmenshan_view2", "tianmenshan_view2"]
            trackDetailViewModel.trackTitle = "天门山通天大道"
            trackDetailViewModel.trackDetail = "天门山位于湖南省张家界市永定区，被称为通天大道的盘山公路共计99弯，暗合了“天有九重，云有九霄”之意。"
            trackDetailViewModel.trackStarString = "star5"
            //destController.trackMap = "tianmenshan_map"
        default:
            break
        }
        destController.trackDetailViewModel = trackDetailViewModel
    }

}
