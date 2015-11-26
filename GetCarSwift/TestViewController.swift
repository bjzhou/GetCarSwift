//
//  TestViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class TestViewController: UIViewController {

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()


        //        for score in realm.objects(RmScore) {
        //            if let data = try? NSJSONSerialization.dataWithJSONObject(score.toDictionary(), options: []) {
        //                print(String(data: data, encoding: NSUTF8StringEncoding))
        //            }
        //        }
    }

    @IBAction func didClick(sender: UIButton) {
        /*
        dynamic var t = 0.0
        dynamic var v = 0.0
        dynamic var a = 0.0
        dynamic var s = 0.0
        dynamic var lat = 0.0
        dynamic var long = 0.0
        dynamic var alt = 0.0
        */
        if let v60 = realm.objects(RmScore).filter("type = 'v60'").last {
            _ = GaikeService.sharedInstance.upload("upload/uploadRecord", parameters: ["map_type": 0, "duration": v60.score], datas: ["record": v60.asData()]).subscribeNext { (res: GKResult<String>) in
                print(res)
                }
        }
    }

}
