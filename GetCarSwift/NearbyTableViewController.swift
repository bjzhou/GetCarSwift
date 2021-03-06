//
//  NearbyTableViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/29.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class NearbyTableViewController: UITableViewController {

    let disposeBag = DisposeBag()
    var nearbys: [Nearby] = []
//    var bottomIndicator: UIActivityIndicatorView?
//    var loading = false
//    var canLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.rx.controlEvent(.valueChanged).subscribe(onNext: {
            self.loadData()
        }).addDisposableTo(disposeBag)

        loadData()

//        bottomIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//        bottomIndicator?.startAnimating()
//        bottomIndicator?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
//        self.tableView.tableFooterView = bottomIndicator!
    }

    func loadData() {
        _ = Nearby.map().do { (event) -> Void in
            self.refreshControl?.endRefreshing()
        }.subscribe(onNext: { res in
            guard let nearbys = res.dataArray else {
                return
            }
            self.nearbys = nearbys
            self.tableView.reloadData()
        })
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nearby = nearbys[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearby", for: indexPath) as? FriendTableViewCell
        cell?.id = nearby.uid
        cell?.headerImageView.updateAvatar(nearby.uid, url: nearby.headUrl, inVC: self)
        cell?.nicknameLabel.text = nearby.nickname
        cell?.sexImageView.image = nearby.sex == 1 ? UIImage(named: "mine_male") : UIImage(named: "mine_female")
        let distance = DeviceDataService.sharedInstance.rxLocation.value?.distance(from: CLLocation(latitude: nearby.lati, longitude: nearby.longt)) ?? 0
        if distance >= 1000 {
            cell?.descLabel.text = String(format: "%.0fkm", distance / 1000)
        } else {
            cell?.descLabel.text = String(format: "%.0fm", distance)
        }
        cell?.followButton.isSelected = (nearby.friendStatus == 0 || nearby.friendStatus == 1)
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nearby = nearbys[(indexPath as NSIndexPath).row]
        let chat = ConversationViewController()
        chat.hidesBottomBarWhenPushed = true
        chat.conversationType = RCConversationType.ConversationType_PRIVATE
        chat.targetId = nearby.uid
        chat.title = nearby.nickname
        showViewController(chat)
    }

//    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        if scrollView.contentOffset.y + scrollView.frame.height + (bottomIndicator?.frame.height ?? 0) > scrollView.contentSize.height {
//            if canLoad && !loading {
//                loading = true
//                loadMore()
//            }
//        }
//    }

//    func loadMore() {
//        delay(1) {
//            if self.count >= 30 {
//                self.tableView.tableFooterView = nil
//                self.canLoad = false
//            } else {
//                self.count += 10
//            }
//            self.loading = false
//            self.tableView.reloadData()
//        }
//    }

}
