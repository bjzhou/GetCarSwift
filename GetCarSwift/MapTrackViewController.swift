//
//  MapTrackViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/4.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class MapTrackViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackAddressButton: UIButton!
    @IBOutlet weak var gotoTrackButton: UIButton!
    @IBOutlet weak var trackIntroButton: UIButton!

    let disposeBag = DisposeBag()
    var raceTrack: RmRaceTrack?

    override func viewDidLoad() {
        super.viewDidLoad()

        trackTitleLabel.text = raceTrack?.name ?? ""
        trackAddressButton.setTitle(raceTrack?.address ?? "", forState: .Normal)
        closeButton.rx_tap.subscribeNext {
            self.dismissPopupViewController(animated: true)
            if let parent = self.parentViewController as? PopupViewController {
                if let sender = parent.sender as? MapViewController {
                    sender.mapView.centerCoordinate = sender.centerCoordinate
                    sender.mapView.setZoomLevel(sender.zoomLevel, animated: true)
                }
            }
        }.addDisposableTo(disposeBag)
        gotoTrackButton.rx_tap.subscribeNext {
            if self.raceTrack?.isDeveloped ?? false {
                let vc = R.storyboard.gkbox.track_timer
                vc!.raceTrack =? self.raceTrack
                if let parent = self.parentViewController as? PopupViewController {
                    if let sender = parent.sender as? UIViewController {
                        self.dismissPopupViewController(animated: true) {
                            sender.showViewController(vc!)
                        }
                    }
                }
            } else {
                let alertController = UIAlertController(title: "正在测绘中", message: nil, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
                if let parent = self.parentViewController as? PopupViewController {
                    if let sender = parent.sender as? UIViewController {
                        self.dismissPopupViewController(animated: true) {
                            sender.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }.addDisposableTo(disposeBag)
        trackAddressButton.rx_tap.subscribeNext {
            let name = self.raceTrack?.name.encodedUrlString ?? ""
            let address = self.raceTrack?.address.encodedUrlString ?? ""
            let lat = self.raceTrack?.mapCenter?.latitude ?? 0
            let long = self.raceTrack?.mapCenter?.longitude ?? 0
            let gaodeUrl = "iosamap://viewMap?sourceApplication=\(productName!.encodedUrlString)&poiname=\(name)&lat=\(lat)&lon=\(long)&dev=0"
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: gaodeUrl)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: gaodeUrl)!)
            } else {
                let src = "\(bundleId!)|\(productName!)".encodedUrlString
                let baiduUrl = "baidumap://map/geocoder?address=\(address)&src=\(src)"
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: baiduUrl)!) {
                    UIApplication.sharedApplication().openURL(NSURL(string: baiduUrl)!)
                } else {
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?ll=\(lat),\(long)")!)
                }
            }
        }.addDisposableTo(disposeBag)
        trackIntroButton.rx_tap.subscribeNext {
            let vc = R.storyboard.gkbox.track_intro
            vc!.raceTrack =? self.raceTrack
            if let parent = self.parentViewController as? PopupViewController {
                if let sender = parent.sender as? UIViewController {
                    self.dismissPopupViewController(animated: true) {
                        sender.showViewController(vc!)
                    }
                }
            }
        }.addDisposableTo(disposeBag)
    }

}
