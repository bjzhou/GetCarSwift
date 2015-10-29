//
//  MatchViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import SwiftyJSON
import RxSwift

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

    var purpleAnnotation: MAPointAnnotation?
    var yellowAnnotation: MAPointAnnotation?
    var blueAnnotation: MAPointAnnotation?

    var dataList: [[String:Double]] = []
    var timerDisposable: Disposable?

    override func viewDidLoad() {
        initMapView()
        addMe()
    }

    override func viewWillDisappear(animated: Bool) {
        timerDisposable?.dispose()
    }

    func initMapView() {
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 8)
        mapView.zoomLevel = 19
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false

        mapView.setCenterCoordinate(DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), animated: false)
    }

    func addMe() {
        Me.sharedInstance.fetchAvatar { image in
            self.didPlayerAdded(avatar: image, name: "我", sender: self.blueButton)
        }
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
        let addViewController = R.storyboard.trace.add_player_popover!
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 258)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }

    var startPlay = false
    @IBAction func didPlayBack(sender: UIButton) {
        if !startPlay {
            dataList.removeAll()
            startPlay = true
            timerDisposable = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
                let tms = t % 100
                let s = t / 100 % 60
                let m = t / 100 / 60
                self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

                var point: [String:Double] = [:]
                point["lat"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 0
                point["long"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 0
                let speed = DeviceDataService.sharedInstance.rx_location.value?.speed
                point["speed"] = round((speed < 0 ? 0 : speed ?? 0) * 3.6 * 1000) / 1000
                point["accelarate"] = round(abs(DeviceDataService.sharedInstance.rx_acceleration.value?.y ?? 0) * 100) / 10
                self.dataList.append(point)

                self.blueSpeed.text = String(point["speed"]!)
                self.blueAcce.text = String(point["accelarate"]!)

                self.purpleAnnotation?.coordinate.longitude += 0.000001
                self.blueAnnotation?.coordinate.longitude += 0.000001
                self.yellowAnnotation?.coordinate.longitude += 0.000001

                self.mapView.setCenterCoordinate(self.blueAnnotation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0), animated: false)
            }
        } else {
            startPlay = false
            timerDisposable?.dispose()
            timeLabel.text = "00:00.00"
            blueSpeed.text = "0.0"
            blueAcce.text = "0.0"
//            print(dataList)
//            let pasteBoard = UIPasteboard.generalPasteboard()
//            pasteBoard.string = JSON(dataList).rawString()
        }
    }
}

extension MatchViewController: AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String, sender: UIButton?) {
        if let pressedButton = sender {
            pressedButton.setBackgroundImage(avatar, forState: .Normal)
            pressedButton.layer.cornerRadius = pressedButton.frame.size.width / 2
            pressedButton.clipsToBounds = true
            switch pressedButton {
            case purpleButton:
                self.mapView.removeAnnotation(purpleAnnotation)
                purpleTitle.text = name
                purpleAnnotation = MAPointAnnotation()
                purpleAnnotation!.coordinate = CLLocationCoordinate2D(latitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 100 - 0.00005, longitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 100)
                self.mapView.addAnnotation(purpleAnnotation)
                break
            case yellowButton:
                self.mapView.removeAnnotation(yellowAnnotation)
                yellowTitle.text = name
                yellowAnnotation = MAPointAnnotation()
                yellowAnnotation!.coordinate = CLLocationCoordinate2D(latitude: (DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 100) + 0.00005, longitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 100)
                self.mapView.addAnnotation(yellowAnnotation)
                break
            case blueButton:
                self.mapView.removeAnnotation(blueAnnotation)
                blueTitle.text = name
                blueAnnotation = MAPointAnnotation()
                blueAnnotation!.coordinate = CLLocationCoordinate2D(latitude: (DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 100), longitude: DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 100)
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
                annotationView!.image = R.image.purple_small_car
            case let yellow where yellow == yellowAnnotation:
                annotationView!.image = R.image.yellow_small_car
            case let blue where blue == blueAnnotation:
                annotationView!.image = R.image.blue_small_car
            default:
                break
            }

            return annotationView;
        }
        return nil;
    }
}
