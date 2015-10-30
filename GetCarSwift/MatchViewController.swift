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

    @IBOutlet weak var stateLabel: UILabel!

    var recordMode = false

    var mapTitle = "上海浦东软件园"
    var mapCenter = CLLocationCoordinate2D(latitude: 31.2015978929397, longitude: 121.605284651681)
    var mapStartCircle = MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: 31.2000404188507, longitude: 121.604965850096), radius: 10)
    var mapZoomLevel = 16.5

    var purpleAnnotation: MAPointAnnotation?
    var yellowAnnotation: MAPointAnnotation?
    var blueAnnotation: MAPointAnnotation?

    var newDataList: [[String:Double]] = []

    var purpleDataList: [[String:Double]] = []
    var yellowDataList: [[String:Double]] = []
    var blueDataList: [[String:Double]] = []

    var timerDisposable: Disposable?
    var locationDisposable: Disposable?

    override func viewDidLoad() {
        self.title = mapTitle
        initMapView()
        if recordMode {
            addMe()
        }
    }

    var startPlay = false
    var readyPlay = false
    var stopTime = 0

    override func viewDidAppear(animated: Bool) {
        if recordMode {
            locationDisposable = DeviceDataService.sharedInstance.rx_location.subscribeNext { location in
                if let coordinate = location?.coordinate {
                    if MACircleContainsCoordinate(coordinate, self.mapStartCircle.coordinate, 10) {
                        if self.startPlay {
                            self.stateLabel.text = "已结束"
                            self.playOrStop()
                            return
                        }
                        self.stateLabel.text = "准备中"
                        self.readyPlay = true
                    } else {
                        if self.readyPlay {
                            self.stateLabel.text = "进行中"
                            self.readyPlay = false
                            self.playOrStop()
                        }
                    }
                }
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        timerDisposable?.dispose()
        locationDisposable?.dispose()
    }

    func initMapView() {
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 8)
        mapView.zoomLevel = 16.5

        if recordMode {
            mapView.showsUserLocation = true
        }

        mapView.setCenterCoordinate(mapCenter, animated: false)

        mapView.addOverlay(mapStartCircle)
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

    func playOrStop() {
        if !startPlay {
            if recordMode {
                newDataList.removeAll()
            }
            startPlay = true
            timerDisposable = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
                let tms = t % 100
                let s = t / 100 % 60
                let m = t / 100 / 60
                self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

                if self.recordMode {
                    var point: [String:Double] = [:]
                    point["lat"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 0
                    point["long"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 0
                    let speed = DeviceDataService.sharedInstance.rx_location.value?.speed
                    point["speed"] = round((speed < 0 ? 0 : speed ?? 0) * 3.6 * 1000) / 1000
                    point["accelarate"] = round(abs(DeviceDataService.sharedInstance.rx_acceleration.value?.y ?? 0) * 100) / 10
                    self.newDataList.append(point)

                    self.blueSpeed.text = String(point["speed"]!)
                    self.blueAcce.text = String(point["accelarate"]!)

                    self.blueAnnotation?.coordinate = DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D.Zero
                } else {
                    if Int(t) > self.stopTime {
                        self.playOrStop()
                    }
                    if self.blueDataList.count > Int(t) {
                        self.blueAnnotation?.coordinate = CLLocationCoordinate2D(latitude: self.blueDataList[Int(t)]["lat"] ?? 0, longitude: self.blueDataList[Int(t)]["long"] ?? 0)
                        self.blueSpeed.text = "\(self.blueDataList[Int(t)]["speed"])"
                        self.blueAcce.text = "\(self.blueDataList[Int(t)]["accelarate"])"
                    }
                    if self.yellowDataList.count > Int(t) {
                        self.yellowAnnotation?.coordinate = CLLocationCoordinate2D(latitude: self.yellowDataList[Int(t)]["lat"] ?? 0, longitude: self.yellowDataList[Int(t)]["long"] ?? 0)
                        self.yellowSpeed.text = "\(self.yellowDataList[Int(t)]["speed"])"
                        self.yellowAcce.text = "\(self.yellowDataList[Int(t)]["accelarate"])"
                    }
                    if self.purpleDataList.count > Int(t) {
                        self.purpleAnnotation?.coordinate = CLLocationCoordinate2D(latitude: self.purpleDataList[Int(t)]["lat"] ?? 0, longitude: self.purpleDataList[Int(t)]["long"] ?? 0)
                        self.purpleSpeed.text = "\(self.purpleDataList[Int(t)]["speed"])"
                        self.purpleAcce.text = "\(self.purpleDataList[Int(t)]["accelarate"])"
                    }
                }
            }
        } else {
            startPlay = false
            timerDisposable?.dispose()
            timeLabel.text = "00:00.00"
            blueSpeed.text = "0.0"
            blueAcce.text = "0.0"
            if recordMode {
                NSUserDefaults.standardUserDefaults().setValue(newDataList, forKey: "test\(NSDate().timeIntervalSince1970)")
            }
        }
    }

    @IBAction func didPlayBack(sender: UIButton) {
        if recordMode {
            mapView.removeOverlay(mapStartCircle)
            mapStartCircle = MACircle(centerCoordinate: DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D.Zero, radius: 10)
            mapView.addOverlay(mapStartCircle)

            var map: [String:AnyObject] = [:]
            map["center_lat"] = mapView.centerCoordinate.latitude
            map["center_lng"] = mapView.centerCoordinate.longitude
            map["start_lat"] = mapStartCircle.coordinate.latitude
            map["start_lng"] = mapStartCircle.coordinate.longitude
            map["zoom"] = mapView.zoomLevel
            NSUserDefaults.standardUserDefaults().setValue(map, forKey: mapTitle)
        } else {
            playOrStop()
            stopTime = max(max(blueDataList.count, yellowDataList.count), purpleDataList.count)
        }
    }
}

extension MatchViewController: AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String, sender: UIButton?) {
        if let pressedButton = sender {
            pressedButton.setBackgroundImage(avatar, forState: .Normal)
            pressedButton.layer.cornerRadius = pressedButton.frame.size.width / 2
            pressedButton.clipsToBounds = true
            if pressedButton == blueButton && name == "我" {
                return
            }
            if let dataList = NSUserDefaults.standardUserDefaults().valueForKey(name) as? [[String:Double]] {
                switch pressedButton {
                case purpleButton:
                    purpleDataList = dataList
                    self.mapView.removeAnnotation(purpleAnnotation)
                    purpleTitle.text = name
                    purpleAnnotation = MAPointAnnotation()
                    if let first = dataList.first {
                        purpleAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first["lat"] ?? 0, longitude: first["long"] ?? 0)
                    }
                    self.mapView.addAnnotation(purpleAnnotation)
                    break
                case yellowButton:
                    yellowDataList = dataList
                    self.mapView.removeAnnotation(yellowAnnotation)
                    yellowTitle.text = name
                    yellowAnnotation = MAPointAnnotation()
                    if let first = dataList.first {
                        yellowAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first["lat"] ?? 0, longitude: first["long"] ?? 0)
                    }
                    self.mapView.addAnnotation(yellowAnnotation)
                    break
                case blueButton:
                    blueDataList = dataList
                    self.mapView.removeAnnotation(blueAnnotation)
                    blueTitle.text = name
                    blueAnnotation = MAPointAnnotation()
                    if let first = dataList.first {
                        blueAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first["lat"] ?? 0, longitude: first["long"] ?? 0)
                    }
                    self.mapView.addAnnotation(blueAnnotation)
                    break
                default:
                    break
                }
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
        if annotation.isKindOfClass(MAUserLocation) {
            let userLocationStyleReuseIndetifier = "userLocationStyleReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(userLocationStyleReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: userLocationStyleReuseIndetifier)
            }
            annotationView.image = R.image.blue_small_car
            annotationView.canShowCallout = true

            return annotationView
        }
        return nil;
    }

    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MACircle) {
            let circleView = MACircleView(overlay: overlay)
            circleView.lineWidth = 1
            circleView.strokeColor = UIColor.redColor()
            circleView.fillColor = UIColor.yellowColor()

            return circleView
        }
        return nil
    }
}
