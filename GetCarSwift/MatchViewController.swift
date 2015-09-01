//
//  MatchViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import SwiftyJSON

class MatchViewController: UIViewController {
    
    @IBOutlet weak var mapView: MAMapView!

    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet weak var purpleTitle: UILabel!
    @IBOutlet weak var yellowTitle: UILabel!
    @IBOutlet weak var blueTitle: UILabel!

    @IBOutlet weak var purpleSpeed: UILabel!
    @IBOutlet weak var yellowSpeed: UILabel!
    @IBOutlet weak var blueSpeed: UILabel!

    @IBOutlet weak var purpleAcce: UILabel!
    @IBOutlet weak var yellowAcce: UILabel!
    @IBOutlet weak var blueAcce: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    var pressedButton: UIButton?

    var dataList: [Double:[String:Double]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView()
    }
    
    func initMapView() {
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 44)
        mapView.zoomLevel = 17
    }
    
    @IBAction func locationButtonAction(sender: UIButton) {
        mapView.userTrackingMode = MAUserTrackingModeFollow
    }
    
    @IBAction func zoomInButtonAction(sender: UIButton) {
        if mapView.zoomLevel >= 20 {
            return
        }
        
        mapView.setZoomLevel(mapView.zoomLevel+1, animated: true)
    }
    
    @IBAction func zoomOutButtonAction(sender: UIButton) {
        if mapView.zoomLevel <= 3 {
            return
        }
        
        mapView.setZoomLevel(mapView.zoomLevel-1, animated: true)
    }

    @IBAction func didAddPlayer(sender: UIButton) {
        pressedButton = sender
        let addViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("add_player_popover") as! AddPlayerTableViewController
        addViewController.delegate = self
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 258)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }

    var curTime = 0
    var startPlay = false
    @IBAction func didPlayBack(sender: UIButton) {
        if !startPlay {
            dataList.removeAll()
            startPlay = true
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("didPlayUpdate:"), userInfo: nil, repeats: true).fire()
        } else {
            curTime = 0
            startPlay = false
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.string = JSON(dataList).rawString()
        }
    }

    func didPlayUpdate(sender: NSTimer) {
        if !startPlay {
            timeLabel.text = "00:00.00"
            blueSpeed.text = "0.0"
            blueAcce.text = "0.0"
            sender.invalidate()
            return
        }

        curTime++
        let tms = curTime % 100
        let s = curTime / 100 % 60
        let m = curTime / 100 / 60
        timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

        if curTime % 100 == 0 {
            var point: [String:Double] = [:]
            point["lat"] = DataKeeper.sharedInstance.location?.coordinate.latitude ?? 0
            point["long"] = DataKeeper.sharedInstance.location?.coordinate.longitude ?? 0
            let speed = DataKeeper.sharedInstance.location?.speed
            point["speed"] = round((speed < 0 ? 0 : speed ?? 0) * 3.6 * 1000) / 1000
            point["accelarate"] = round(abs(DataKeeper.sharedInstance.acceleration?.y ?? 0) * 100) / 10
            dataList[Double(curTime) / 100.0] = point

            blueSpeed.text = String(point["speed"]!)
            blueAcce.text = String(point["accelarate"]!)
        }
    }
}

extension MatchViewController: AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String) {
        if let pressedButton = pressedButton {
            pressedButton.setBackgroundImage(avatar, forState: .Normal)
            pressedButton.layer.cornerRadius = pressedButton.frame.size.width / 2
            pressedButton.clipsToBounds = true
            switch pressedButton {
            case purpleButton:
                purpleTitle.text = name
                break
            case yellowButton:
                yellowTitle.text = name
                break
            case blueButton:
                blueTitle.text = name
                break
            default:
                break
            }
        }
    }
}
