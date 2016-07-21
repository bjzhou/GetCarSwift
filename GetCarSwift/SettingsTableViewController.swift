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

    override func viewDidLoad() {
        super.viewDidLoad()

        closeDanmu.setOn(UserDefaults.standard.bool(forKey: "closeDanmu"), animated: false)
        _ = closeDanmu.rx_value.takeUntil(self.rx_deallocated).subscribeNext { on in
            UserDefaults.standard.set(on, forKey: "closeDanmu")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 1 {
                let alertController = UIAlertController(title: "清除缓存", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                    KingfisherManager.sharedManager.cache.clearDiskCache()
                    gRealm?.writeOptional {
                        if let objects = gRealm?.allObjects(ofType: RmScore.self) {
                            gRealm?.delete(objects)
                        }
                        if let objects = gRealm?.allObjects(ofType: RmScoreData.self) {
                            gRealm?.delete(objects)
                        }
                        if let objects = gRealm?.allObjects(ofType: CarInfo.self) {
                            gRealm?.delete(objects)
                        }
                    }
                    Toast.makeToast(message: "清除成功")
                    })
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }

        if (indexPath as NSIndexPath).section == 2 {
            Mine.sharedInstance.logout(expired: false)
        }
    }

}
