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
import SafariServices

class ShareScoreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let scoreTitles = ["成绩", "车型"]
    var scoreValues = ["选择成绩", "选择车型"]

    var carInfo = CarInfo()
    var share = Share()
    var score = RmScore()

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
        uploadShare {
            if #available(iOS 9, *) {
                let vc = SFSafariViewController(URL: self.share.getShareUrl())
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                let webBrowser = WebViewController()
                webBrowser.loadURL(self.share.getShareUrl())
                self.showViewController(webBrowser, sender: self)
            }
        }
    }

    @IBAction func didShareAction(sender: UIButton) {
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
        let req = SendMessageToWXReq()
        let msg = WXMediaMessage()
        msg.title = "测试分享标题..."
        msg.description = "测试分享描述..."
        msg.setThumbImage(R.image.app_icon!)
        let mediaObject = WXWebpageObject()
        mediaObject.webpageUrl = self.share.getShareUrl().URLString
        msg.mediaObject = mediaObject
        req.message = msg
        req.bText = false
        req.scene = scene
        WXApi.sendReq(req)
    }

    func uploadShare(succeed: () -> Void) {
        if share.id == "" {
            self.view.makeToastActivity()
            let imageKeys = self.carInfo.parts.map { $0.imageKey }
            async {
                let images = imageKeys.map { KingfisherManager.sharedManager.cache.retrieveImageInDiskCacheForKey($0) ?? UIImage()}
                main {
                    _ = Share.uploadShare(self.scoreValues[0], liushikm: String(self.score.data.filter { $0.v == 60 }.first?.t ?? 0), yibaikm: String(self.score.data.filter { $0.v == 100 }.first?.t ?? 0), maxa: String(((self.score.data.map { $0 }).maxElement { $0.0.a > $0.1.a }) ?? 0), maxv: String(((self.score.data.map { $0 }).maxElement { $0.0.v > $0.1.v }) ?? 0), title: "0~400m直线赛道", carId: self.carInfo.model, carDesc: self.carInfo.detail, partDescs: self.carInfo.parts.map { $0.detail }, partImages: images).subscribeNext { (res) -> Void in
                        if let share = res.data {
                            self.view.hideToastActivity()
                            self.share = share
                            succeed()
                        }
                    }
                }
            }
        } else {
            succeed()
        }
    }

}

extension ShareScoreViewController: UITableViewDelegate, UITableViewDataSource, AddPlayerDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + carInfo.parts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row <= 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.share_score, forIndexPath: indexPath)
            cell?.scoreTitleLabel.text = scoreTitles[indexPath.row]
            cell?.scoreLabel.text = scoreValues[indexPath.row]
            cell?.addDisposable?.dispose()
            cell?.addDisposable = cell?.addButton.rx_tap.subscribeNext {
                let addViewController = AddPlayerTableViewController()
                addViewController.delegate = self
                addViewController.mode = indexPath.row == 0 ? .Myself : .Car
                addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 380)
                let popupViewController = PopupViewController(rootViewController: addViewController)
                self.presentViewController(popupViewController, animated: false, completion: nil)
            }
            return cell!
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.share_part, forIndexPath: indexPath)
        let part = carInfo.parts[indexPath.row - 2]
        cell?.partTitleLabel.text = part.title
        cell?.partDetailLabel.text = part.detail
        cell?.partImageView.image = nil
        KingfisherManager.sharedManager.cache.retrieveImageForKey(part.imageKey, options: KingfisherManager.OptionsNone) { image, _ in
            cell?.partImageView.image = image
        }
        return cell!
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row <= 1 {
            return 64
        }
        return 120
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.row > 1 {
            let vc = R.storyboard.mine.car_detail
            vc?.id = carInfo.id
            showViewController(vc!)
        }
    }

    func didPlayerAdded(record: AnyObject, sender: UIButton?) {
        if let carInfo = record as? CarInfo {
            self.carInfo = carInfo
            scoreValues[1] = carInfo.model
        }

        if let score = record as? RmScore {
            self.score = score
            scoreValues[0] = String(format: "%.2f", score.score)
        }

        share.id = ""
        tableView.reloadData()
    }
}
