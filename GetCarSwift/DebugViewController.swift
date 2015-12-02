//
//  DebugViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class DebugViewController: UIViewController {

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didClick(sender: UIButton) {
        for score in realm.objects(RmScore).filter("mapType = 0") {
            if score.score <= 1 { continue }
            _ = Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribeNext { res in
                print(res)
                }
        }
        for score in realm.objects(RmScore).filter("mapType = 1001") {
            if score.score <= 1 { continue }
            _ = Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribeNext { res in
                print(res)
            }
        }
        for score in realm.objects(RmScore).filter("mapType = 1002") {
            if score.score <= 1 { continue }
            _ = Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribeNext { res in
                print(res)
            }
        }
        for score in realm.objects(RmScore).filter("mapType = 1003") {
            if score.score <= 1 { continue }
            _ = Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribeNext { res in
                print(res)
            }
        }
    }

}
