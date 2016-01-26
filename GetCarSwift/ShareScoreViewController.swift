//
//  ShareScoreViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import Kingfisher

class ShareScoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let scoreTitles = ["赛道", "成绩", "车型"]
    var scoreValues = ["选择赛道", "选择成绩", "选择车型"]
    var menuCount = 1

    var carInfo = CarInfo()
    var share = Share()
    var score = RmScore()

    var selectedTrack = RmRaceTrack()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        share.id = ""
        tableView.reloadData()
    }

    @IBAction func didPreviewAction(sender: UIButton) {
        if scoreValues[1] == "选择成绩" {
            Toast.makeToast(message: "请选择成绩")
            return
        }
        if scoreValues[2] == "选择车型" {
            Toast.makeToast(message: "请选择车型")
            return
        }
        uploadShare {
            let webBrowser = WebViewController()
            webBrowser.loadURL(self.share.getShareUrl())
            self.showViewController(webBrowser, sender: self)
        }
    }

    @IBAction func didShareAction(sender: UIButton) {
        if scoreValues[1] == "选择成绩" {
            Toast.makeToast(message: "请选择成绩")
            return
        }
        if scoreValues[2] == "选择车型" {
            Toast.makeToast(message: "请选择车型")
            return
        }
        uploadShare {
            // share to wechat
            let actionSheet = UIAlertController(title: "分享", message: nil, preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "分享给微信好友", style: .Default, handler: { _ in
                self.shareToWechat(Int32(WXSceneSession.rawValue))
            }))
            actionSheet.addAction(UIAlertAction(title: "分享到朋友圈", style: .Default, handler: { _ in
                self.shareToWechat(Int32(WXSceneTimeline.rawValue))
            }))
            actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
    }

    func shareToWechat(scene: Int32) {
        _ = Share.getShareTitle(self.scoreValues[1], userCarId: self.carInfo.carUserId).subscribeNext { res in
            guard let share = res.data else {
                return
            }
            let req = SendMessageToWXReq()
            let msg = WXMediaMessage()
            msg.title = share.title
            msg.description = share.desc
            msg.setThumbImage(R.image.app_icon!)
            let mediaObject = WXWebpageObject()
            mediaObject.webpageUrl = self.share.getShareUrl().URLString
            msg.mediaObject = mediaObject
            req.message = msg
            req.bText = false
            req.scene = scene
            WXApi.sendReq(req)
        }
    }

    func uploadShare(succeed: () -> Void) {
        if share.id == "" {
            Toast.makeToastActivity()
            var liushikm: String? = nil
            var yibaikm: String? = nil
            if selectedTrack.id == 0 {
                liushikm = String(self.score.data.filter { $0.v == 60 }.first?.t ?? 0)
                yibaikm = String(self.score.data.filter { $0.v == 100 }.first?.t ?? 0)
            }
            _ = Share.uploadShare(self.scoreValues[1], liushikm: liushikm, yibaikm: yibaikm, maxa: String(((self.score.data.map { $0 }).maxElement { $0.0.a > $0.1.a }) ?? 0), maxv: String(((self.score.data.map { $0 }).maxElement { $0.0.v > $0.1.v }) ?? 0), title: selectedTrack.name, userCarId: self.carInfo.carUserId, carDesc: self.carInfo.detail).subscribeNext { (res) -> Void in
                if let share = res.data {
                    Toast.hideToastActivity()
                    self.share = share
                    succeed()
                }
            }
        } else {
            succeed()
        }
    }

}

extension ShareScoreViewController: UITableViewDelegate, UITableViewDataSource, AddPlayerDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuCount + carInfo.parts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row <= 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.share_score, forIndexPath: indexPath)
            cell?.scoreTitleLabel.text = scoreTitles[indexPath.row]
            cell?.scoreLabel.text = scoreValues[indexPath.row]
            cell?.addDisposable?.dispose()
            cell?.addDisposable = cell?.addButton.rx_tap.subscribeNext {
                let addViewController = AddPlayerTableViewController()
                addViewController.delegate = self
                switch indexPath.row {
                case 0:
                    addViewController.mode = .Track
                case 1:
                    addViewController.sid = self.selectedTrack.id
                    addViewController.mode = .Myself
                case 2:
                    addViewController.mode = .Car
                default:
                    break
                }
                addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 380)
                let popupViewController = PopupViewController(rootViewController: addViewController)
                self.presentViewController(popupViewController, animated: false, completion: nil)
            }
            return cell!
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.share_part, forIndexPath: indexPath)
        let part = carInfo.parts[indexPath.row - 3]
        cell?.partTitleLabel.text = part.title
        cell?.partDetailLabel.text = part.detail
        cell?.partImageView.kf_setImageWithURL(NSURL(string: part.imageUrl)!)
        return cell!
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row <= 2 {
            return 64
        }
        return 120
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.row > 2 {
            let vc = R.storyboard.mine.car_detail
            vc?.id = carInfo.id
            showViewController(vc!)
        }
    }

    func didPlayerAdded(record: AnyObject, sender: UIButton?) {
        if let carInfo = record as? CarInfo {
            self.carInfo = carInfo
            carInfo.fetchParts {
                self.tableView.reloadData()
            }
            scoreValues[2] = carInfo.model
        }

        if let track = record as? RmRaceTrack {
            self.selectedTrack = track
            scoreValues[0] = track.name
            scoreValues[1] = "选择成绩"
            menuCount = 2
        }

        if let score = record as? RmScore {
            self.score = score
            scoreValues[1] = String(format: "%.2f", score.score)
            menuCount = 3
        }

        share.id = ""
        tableView.reloadData()
    }
}
