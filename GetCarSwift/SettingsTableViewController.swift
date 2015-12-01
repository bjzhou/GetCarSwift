//
//  SettingsTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/25.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var closeDanmu: UISwitch!

    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        closeDanmu.setOn(NSUserDefaults.standardUserDefaults().boolForKey("closeDanmu"), animated: false)
        _ = closeDanmu.rx_value.subscribeNext { on in
            NSUserDefaults.standardUserDefaults().setBool(on, forKey: "closeDanmu")
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 1 {
            if indexPath.row == 1 {
                let alertController = UIAlertController(title: "清除缓存", message: nil, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .Default) { _ in
                    KingfisherManager.sharedManager.cache.clearDiskCache()
                    try! self.realm.write {
                        self.realm.delete(self.realm.objects(RmScore))
                    }
                    self.view.makeToast(message: "清除成功")
                    })
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                presentViewController(alertController, animated: true, completion: nil)
            }
        }

        if indexPath.section == 2 {
            Mine.sharedInstance.logout()
        }
    }

}
