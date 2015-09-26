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

    var purpleAnnotation: MAPointAnnotation?
    var yellowAnnotation: MAPointAnnotation?
    var blueAnnotation: MAPointAnnotation?

    var dataList: [[String:Double]] = []

    override func viewDidLoad() {
        initMapView()
    }
    
    func initMapView() {
        mapView.centerCoordinate = DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 8)
        mapView.zoomLevel = 17
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
        let addViewController = traceStoryboard.instantiateViewControllerWithIdentifier("add_player_popover") as! AddPlayerTableViewController
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
            print(dataList)
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
        let tms = curTime % 100
        let s = curTime / 100 % 60
        let m = curTime / 100 / 60
        timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

        if curTime % 100 == 0 {
            var point: [String:Double] = [:]
            point["lat"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 0
            point["long"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 0
            let speed = DeviceDataService.sharedInstance.rx_location.value?.speed
            point["speed"] = round((speed < 0 ? 0 : speed ?? 0) * 3.6 * 1000) / 1000
            point["accelarate"] = round(abs(DeviceDataService.sharedInstance.rx_acceleration.value?.y ?? 0) * 100) / 10
            dataList.append(point)

            blueSpeed.text = String(point["speed"]!)
            blueAcce.text = String(point["accelarate"]!)

            purpleAnnotation?.coordinate.longitude += 0.001
            blueAnnotation?.coordinate.longitude += 0.001
            yellowAnnotation?.coordinate.longitude += 0.001
        }
        curTime++
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
                self.mapView.removeAnnotation(purpleAnnotation)
                purpleTitle.text = name
                purpleAnnotation = MAPointAnnotation()
                purpleAnnotation!.coordinate = CLLocationCoordinate2D(latitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 100, longitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 100)
                self.mapView.addAnnotation(purpleAnnotation)
                break
            case yellowButton:
                self.mapView.removeAnnotation(yellowAnnotation)
                yellowTitle.text = name
                yellowAnnotation = MAPointAnnotation()
                yellowAnnotation!.coordinate = CLLocationCoordinate2D(latitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 100 + 0.01, longitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 100)
                self.mapView.addAnnotation(yellowAnnotation)
                break
            case blueButton:
                self.mapView.removeAnnotation(blueAnnotation)
                blueTitle.text = name
                blueAnnotation = MAPointAnnotation()
                blueAnnotation!.coordinate = CLLocationCoordinate2D(latitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 100 - 0.01, longitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 100)
                self.mapView.addAnnotation(blueAnnotation)
                break
            default:
                break
            }
        }
    }
}

extension MatchViewController: MAMapViewDelegate {
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKindOfClass(MAPointAnnotation) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier) as? MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier) as MAPinAnnotationView
            }
            annotationView!.canShowCallout = false
            annotationView!.animatesDrop = false
            annotationView!.draggable = false

            switch annotation as! MAPointAnnotation {
            case let purple where purple == purpleAnnotation:
                annotationView!.image = UIImage(named: "purple_small_car")
            case let yellow where yellow == yellowAnnotation:
                annotationView!.image = UIImage(named: "yellow_small_car")
            case let blue where blue == blueAnnotation:
                annotationView!.image = UIImage(named: "blue_small_car")
            default:
                break
            }

            return annotationView;
        }
        return nil;
    }
}
