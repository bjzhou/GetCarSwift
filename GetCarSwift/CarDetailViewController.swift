//
//  CarDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class CarDetailViewController: UITableViewController {

    let defaultImage = UIImage().scaleImage(size: CGSize(width: 41, height: 41))

    var id = 0
    var carInfo: CarInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 120
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        carInfo = gRealm?.allObjects(ofType: CarInfo.self).filter(using: "id = \(id)").first
        if let carInfo = carInfo {
            tableView.reloadData()
            carInfo.fetchParts {
                self.tableView.reloadData()
            }
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + (carInfo?.parts.count ?? 0)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.car_detail_model, for: indexPath)
            cell?.logoView.kf_setImageWithURL(URL(string: carInfo?.imageUrl ?? "")!, placeholderImage: defaultImage)
            cell?.titleLabel.text = carInfo?.model ?? "填写车辆信息"
            return cell!
        }

        if (indexPath as NSIndexPath).row == tableView.numberOfRows(inSection: 0) - 1 {
            let cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.car_detail_add, for: indexPath)
            cell?.addDisposable?.dispose()
            cell?.addDisposable = cell?.button.rx_tap.subscribeNext {
                let vc = R.storyboard.mine.add_part
                vc?.id = self.id
                self.showViewController(vc!)
            }
            return cell!
        }

        let cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.car_detail_part, for: indexPath)
        let part = carInfo?.parts[(indexPath as NSIndexPath).row-1]
        cell?.partImageView.kf_setImageWithURL(URL(string: part?.imageUrl ?? "")!)
        cell?.titleLabel.text = part?.title ?? ""
        cell?.detailLabel.text = part?.detail ?? ""
        cell?.delDisposable?.dispose()
        cell?.delDisposable = cell?.delButton.rx_tap.subscribeNext {
            let alertVC = UIAlertController(title: "确定要删除该配件吗", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "否", style: .cancel, handler: nil))
            alertVC.addAction(UIAlertAction(title: "是", style: .default, handler: { _ in
                if let id = part?.id {
                    _ = CarInfo.deleteUserCarPart(id).subscribe()
                }
                self.carInfo?.parts.remove(at: indexPath.row-1)
                tableView.reloadData()
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return 61
        }

        if (indexPath as NSIndexPath).row == tableView.numberOfRows(inSection: 0) - 1 {
            return 52
        }

        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            let vc = R.storyboard.mine.add_car
            vc?.id = id
            showViewController(vc!)
        } else if (indexPath as NSIndexPath).row != tableView.numberOfRows(inSection: 0) - 1 {
            if let part = carInfo?.parts[(indexPath as NSIndexPath).row-1] {
                let vc = R.storyboard.mine.add_part
                vc?.carPart = part
                vc?.isNewPart = false
                showViewController(vc!)
            }
        }
    }

}
