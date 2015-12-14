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

        items = gRealm?.objects(RmRaceTrack).sorted("isDeveloped", ascending: false).map { $0 } ?? []
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

    func getTrackBg(imageView: UIImageView, index: Int) {
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.track_item, forIndexPath: indexPath)

        if self.items[indexPath.row].isDeveloped {
            cell!.mask.backgroundColor = UIColor.clearColor()
            cell!.selectionStyle = .Default
        } else {
            cell!.mask.backgroundColor = UIColor(white: 0, alpha: 0.8)
            cell!.selectionStyle = .None
        }

        cell!.delegate = self
        getTrackBg(cell!.trackBg, index: indexPath.row)
        cell!.trackStar.image = UIImage(named: items[indexPath.row].star)

        cell!.sid = items[indexPath.row].id
        cell!.trackLabel.text = items[indexPath.row].name
        cell!.hideStar = indexPath.row == 0

        let praiseCount = praises.filter { $0.sid == items[indexPath.row].id }.first
        if let praiseCount = praiseCount {
            cell!.loveButton.selected = praiseCount.status == 1
            cell!.lovedCount = praiseCount.count
        } else {
            cell!.loveButton.selected = false
            cell!.lovedCount = 0
        }

        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if items[indexPath.row].id == 0 {
            showViewController(R.storyboard.track.straightMatch!)
        } else {
            if !items[indexPath.row].isDeveloped {
                return
            }
            let vc = R.storyboard.track.track_detail
            var trackDetailViewModel = TrackDetailViewModel()
            trackDetailViewModel.sid = items[indexPath.row].id
            trackDetailViewModel.raceTrack = items[indexPath.row]
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
