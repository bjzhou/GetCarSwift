//
//  TrackViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

class TrackViewController: UITableViewController {

    let disposeBag = DisposeBag()
    let placeholder = UIImage()

    var items: [RmRaceTrack] = []
    var praises: [PraiseCount] = []

    var images: [Int: UIImage] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        items = gRealm?.allObjects(ofType: RmRaceTrack.self).sorted(onProperty: "isDeveloped", ascending: false).map { $0 } ?? []
        updatePraises()
    }

    func updatePraises() {
        Praise.getPraiseList().subscribeNext { res in
            if let arr = res.dataArray {
                self.praises = arr
                self.tableView.reloadData()
            }
            }.addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        images.removeAll()
    }

    func getTrackBg(_ imageView: UIImageView, index: Int) {
        if let image = images[index] {
            imageView.image = image
        } else {
            imageView.image = placeholder
            items[index].getSightViewImage { img in
                imageView.image = img
                self.images[index] = img
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: R.reuseIdentifier.track_item, for: indexPath)

        if self.items[(indexPath as NSIndexPath).row].isDeveloped {
//            cell!.mask?.backgroundColor = UIColor.clear()
            cell!.selectionStyle = .default
        } else {
//            cell!.mask?.backgroundColor = UIColor(white: 0, alpha: 0.8)
            cell!.selectionStyle = .none
        }

        cell!.delegate = self
        getTrackBg(cell!.trackBg, index: (indexPath as NSIndexPath).row)
        cell!.trackStar.image = UIImage(named: items[(indexPath as NSIndexPath).row].star)

        cell!.sid = items[(indexPath as NSIndexPath).row].id
        cell!.trackLabel.text = items[(indexPath as NSIndexPath).row].name
        cell!.hideStar = (indexPath as NSIndexPath).row == 0

        let praiseCount = praises.filter { $0.sid == items[(indexPath as NSIndexPath).row].id }.first
        if let praiseCount = praiseCount {
            cell!.loveButton.isSelected = praiseCount.status == 1
            cell!.lovedCount = praiseCount.count
        } else {
            cell!.loveButton.isSelected = false
            cell!.lovedCount = 0
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[(indexPath as NSIndexPath).row].id == 0 {
            showViewController(R.storyboard.track.straightMatch!)
        } else {
            if !items[(indexPath as NSIndexPath).row].isDeveloped {
                return
            }
            let vc = R.storyboard.track.track_detail
            var trackDetailViewModel = TrackDetailViewModel()
            trackDetailViewModel.sid = items[(indexPath as NSIndexPath).row].id
            trackDetailViewModel.raceTrack = items[(indexPath as NSIndexPath).row]
            vc?.trackDetailViewModel = trackDetailViewModel
            showViewController(vc!)
        }
    }
}

extension TrackViewController: TrackCellDelegate {
    func didTrackChanged() {
        self.updatePraises()
    }
}
