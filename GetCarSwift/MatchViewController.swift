//
//  MatchViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    @IBOutlet weak var mapView: MAMapView!

    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet weak var purpleTitle: UILabel!
    @IBOutlet weak var yellowTitle: UILabel!
    @IBOutlet weak var blueTitle: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    var pressedButton: UIButton?

    var dataList: [[String:Double]] = [[:]]

    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView()
    }
    
    func initMapView() {
        mapView.delegate = self
        mapView.userTrackingMode = MAUserTrackingModeFollow
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 44)
        mapView.zoomLevel = 17
        mapView.showsUserLocation = true
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
            startPlay = true
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("didPlayUpdate:"), userInfo: nil, repeats: true).fire()
        } else {
            curTime = 0
            startPlay = false
        }
        var firstOrLast: [String:Double] = [:]
        firstOrLast["lat"] = mapView.userLocation.coordinate.latitude
        firstOrLast["long"] = mapView.userLocation.coordinate.longitude
        firstOrLast["speed"] = mapView.userLocation.location.speed * 3.6
        //firstOrLast["accelarate"] = mapView.userLocation.location
        dataList.append(firstOrLast)
    }

    func didPlayUpdate(sender: NSTimer) {
        if !startPlay {
            sender.invalidate()
            return
        }

        curTime++
        let tms = curTime % 100
        let s = curTime / 100 % 60
        let m = curTime / 100 / 60
        timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])
    }

}

extension MatchViewController: MAMapViewDelegate {
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation && startPlay {

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
