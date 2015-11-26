//
//  MainViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        let anji = RmRaceTrack(value: ["id": "1", "name": "安吉天荒坪", "address": "安吉天荒坪", "isDeveloped": false, "mapCenter": [30.4600651679568, 119.599765503284, 0.0], "mapZoom": 15, "startLoc": [30.4620881289806, 119.592864948279, 873.360037027606], "stopLoc": [30.4600850062744, 119.599697063361, 792.429000178234], "cycle": false])
        let tianma = RmRaceTrack(value: ["id": "2", "name": "上海天马赛车场", "address": "上海市松江区沈砖公路3000号", "isDeveloped": true, "mapCenter": [31.075861269594, 121.120193376859, 0], "mapZoom": 16.3, "startLoc": ["latitude": 31.0767290992663, "longitude": 121.118461205797], "leaveLoc": [31.076772747002, 121.12084837178, 0], "passLocs": [["latitude": 31.074202813552, "longitude": 121.122138209538], ["latitude": 31.0765154547976, "longitude": 121.119096889323], ["latitude": 31.0752325428113, "longitude": 121.121573354806], ["latitude": 31.0773631380887, "longitude": 121.117991819228]], "cycle": true])
        try! realm.write {
            realm.add(tianma, update: true)
            realm.add(anji, update: true)
        }

        self.addChildViewController(R.storyboard.gkbox.initialViewController!)
        self.addChildViewController(R.storyboard.mod.initialViewController!)
        self.addChildViewController(R.storyboard.track.initialViewController!)
        self.addChildViewController(R.storyboard.mine.initialViewController!)

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gaikeRedColor()], forState:.Selected)

        //UILabel.appearance().font = UIFont.systemFontOfSize()

    }

    override func viewDidLayoutSubviews() {
        for item in self.tabBar.items! {
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
        }
    }
}
