//
//  CarDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher

class CarDetailViewController: UITableViewController {

    var id = 0
    var carInfo: CarInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 120
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        carInfo = gRealm?.objects(CarInfo).filter("id = \(id)").first
        if let _ = carInfo {
            tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + (carInfo?.parts.count ?? 0)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.car_detail_model, forIndexPath: indexPath)
            cell?.imageView?.image = R.image.example_car_logo_small
            cell?.textLabel?.text = carInfo?.model ?? "填写车辆信息"
            return cell!
        }

        if indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.car_detail_add, forIndexPath: indexPath)
            _ = cell?.button.rx_tap.takeUntil(cell!.button.rx_deallocated).subscribeNext {
                let vc = R.storyboard.mine.add_part
                vc?.id = self.id
                self.showViewController(vc!)
            }
            return cell!
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.car_detail_part, forIndexPath: indexPath)
        let part = carInfo?.parts[indexPath.row-1]
        KingfisherManager.sharedManager.cache.retrieveImageForKey(part?.imageKey ?? "", options: KingfisherManager.OptionsNone) { (image, type) -> () in
            cell?.partImageView.image = image
        }
        cell?.titleLabel.text = part?.title ?? ""
        cell?.detailLabel.text = part?.detail ?? ""
        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 61
        }

        if indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            return 52
        }

        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let vc = R.storyboard.mine.add_car
            vc?.id = id
            showViewController(vc!)
        }
    }

}
