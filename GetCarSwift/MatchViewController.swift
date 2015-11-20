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
import RealmSwift

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

    @IBOutlet weak var debugView: UIView!
    @IBOutlet weak var stateLabel: UILabel!

    let realm = try! Realm()

    var recordMode = false

    var mapCenter = CLLocationCoordinate2D(latitude: 30.4600651679568, longitude: 119.599765503284)
    var mapStartCircles: [MACircle] = [MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: 30.4620881289806, longitude: 119.592864948279), radius: 10), MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: 30.4612778365043, longitude: 119.593586889931), radius: 10)]
    var mapStopCircles: [MACircle] = [MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: 30.4600850062744, longitude: 119.599697063361), radius: 10), MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: 30.4627173581684, longitude: 119.592778590697), radius: 10)]

    var raceTrack = RmRaceTrack(value: ["name": "anji"])

    var purpleAnnotation: MAPointAnnotation?
    var yellowAnnotation: MAPointAnnotation?
    var blueAnnotation: MAPointAnnotation?

    var newDataList = List<RmScoreData>()

    var purpleDataList = List<RmScoreData>()
    var yellowDataList = List<RmScoreData>()
    var blueDataList = List<RmScoreData>()

    var _10msTimer: Disposable?
    var locationDisposable: Disposable?

    override func viewDidLoad() {

        if let raceTrack = realm.objects(RmRaceTrack).filter("name = 'anji'").first {
            self.raceTrack = raceTrack
        } else {
            let raceTrack = RmRaceTrack()
            raceTrack.name = "anji"
            raceTrack.mapCenter?.latitude = mapCenter.latitude
            raceTrack.mapCenter?.longitude = mapCenter.longitude
            raceTrack.mapZoom = 16.5
            try! realm.write {
                self.realm.add(raceTrack)
            }
        }

        initMapView()
        if recordMode {
            debugView.hidden = false
            addMe()
        }
    }

    var stopTime = 0.0
    var playing = false
    var ready = false

    override func viewDidAppear(animated: Bool) {

        if recordMode {
            UIApplication.sharedApplication().idleTimerDisabled = true
            locationDisposable = DeviceDataService.sharedInstance.rx_location.subscribeNext { location in
                if let location = location where location.horizontalAccuracy < 65 {
                    if self.stateLabel.text == "正在定位" {
                        self.stateLabel.text = "已定位"
                    }
                    if MACircleContainsCoordinate(location.coordinate, self.mapStartCircles[0].coordinate, 10) {
                        if self.raceTrack.cycle && self.playing && !self.ready {
                            self.stop()
                            self.stateLabel.text = "已结束"
                        }
                        self.playing = false
                        self.ready = true
                        self.stateLabel.text = "已就绪"
                    } else {
                        if MACircleContainsCoordinate(location.coordinate, self.mapStopCircles[0].coordinate, 10) {
                            if !self.raceTrack.cycle && self.playing && !self.ready {
                                self.stop()
                                self.stateLabel.text = "已结束"
                            }
                            self.playing = false
                        }
                        if !self.playing && self.ready {
                            self.play()
                            self.playing = true

                            self.stateLabel.text = "进行中"
                        }
                        self.ready = false
                    }
                } else {
                    self.stateLabel.text = "正在定位"
                }
            }
        }
    }

    func play() {
        if recordMode {
            newDataList.removeAll()
        } else {
            if let blueAnnotation = blueAnnotation {
                startAnim(blueDataList, forView: mapView.viewForAnnotation(blueAnnotation))
            }
            if let yellowAnnotation = yellowAnnotation {
                startAnim(yellowDataList, forView: mapView.viewForAnnotation(yellowAnnotation))
            }
            if let purpleAnnotation = purpleAnnotation {
                startAnim(purpleDataList, forView: mapView.viewForAnnotation(purpleAnnotation))
            }
        }
        _10msTimer?.dispose()
        _10msTimer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let tms = t % 100
            let s = t / 100 % 60
            let m = t / 100 / 60
            self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

            if let loc = DeviceDataService.sharedInstance.rx_location.value {
                if self.recordMode {
                    self.blueAnnotation?.coordinate = loc.coordinate

                    let data = RmScoreData()
                    data.t = Double(t)/100
                    data.a = DeviceDataService.sharedInstance.rx_acceleration.value.averageA()
                    data.v = loc.speed * 3.6
                    data.s = loc.speed * Double(t)/100
                    data.lat = loc.coordinate.latitude
                    data.long = loc.coordinate.longitude
                    data.alt = loc.altitude

                    self.blueSpeed.text = String(format: "%05.1f", data.v)
                    self.blueAcce.text = String(format: "%.1f", data.a)

                    if let prevData = self.newDataList.last {
                        if prevData.lat != data.lat || prevData.long != data.long {
                            data.s = prevData.s + loc.speed * (Double(t)/100 - prevData.t)
                            self.newDataList.append(data)
                        }
                    } else {
                        self.newDataList.append(data)
                    }
                } else {
                    if let blueData = (self.blueDataList.filter { $0.t == Double(t)/100 }.last) {
                        self.blueSpeed.text = String(format: "%05.1f", blueData.v)
                        self.blueAcce.text = String(format: "%.1f", blueData.a)
                    }
                    if let yellowData = (self.yellowDataList.filter { $0.t == Double(t)/100 }.last) {
                        self.blueSpeed.text = String(format: "%05.1f", yellowData.v)
                        self.blueAcce.text = String(format: "%.1f", yellowData.a)
                    }
                    if let purpleData = (self.purpleDataList.filter { $0.t == Double(t)/100 }.last) {
                        self.blueSpeed.text = String(format: "%05.1f", purpleData.v)
                        self.blueAcce.text = String(format: "%.1f", purpleData.a)
                    }

                    if Double(t)/100 >= self.stopTime {
                        self.stop()
                    }
                }
            }
        }
        //testAnim()
    }

    func stop() {
        _10msTimer?.dispose()
        timeLabel.text = "00:00.00"
        blueSpeed.text = "0.0"
        blueAcce.text = "0.0"
        if recordMode {
            let data = List<RmScoreData>()
            data.appendContentsOf(self.newDataList)
            let score = RmScore()
            score.type = "anji"
            score.score = newDataList.last?.t ?? 0
            score.name = Me.sharedInstance.nickname ?? ""
            score.data = data
            try! realm.write {
                self.realm.add(score)
            }
            self.view.makeToast(message: "数据已保存")
        }
    }

    func startAnim(datas: List<RmScoreData>, forView: UIView) {
        let points: [CGPoint] = datas.map { data in
            let loc = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
            return self.mapView.convertCoordinate(loc, toPointToView: self.mapView)
        }
        let path = CGPathCreateMutable()
        CGPathAddLines(path, nil, points, points.count)
        CGPathCloseSubpath(path)

        let lastTime = datas.last?.t ?? 0
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.duration = lastTime
        anim.keyTimes = datas.map { $0.t }
        anim.values = points.map { NSValue(CGPoint: CGPointMake($0.x - points[0].x, $0.y - points[0].y)) }
        anim.calculationMode = kCAAnimationPaced
        anim.rotationMode = kCAAnimationRotateAuto
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.additive = true
        anim.delegate = self

        forView.layer.addAnimation(anim, forKey: "annotation")
    }

    override func viewDidDisappear(animated: Bool) {
        _10msTimer?.dispose()
        locationDisposable?.dispose()
        UIApplication.sharedApplication().idleTimerDisabled = false
    }

    func initMapView() {
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 8)
        mapView.zoomLevel = 16.5

        if recordMode {
            mapView.userTrackingMode = .Follow
            //mapView.showsUserLocation = true
        }

        let loc = CLLocationCoordinate2D(latitude: raceTrack.mapCenter?.latitude ?? 0, longitude: raceTrack.mapCenter?.longitude ?? 0)
        //mapStartCircle = MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: raceTrack.startLat, longitude: raceTrack.startLong), radius: 10)
        //mapStopCircle = MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: raceTrack.stopLat, longitude: raceTrack.stopLong), radius: 10)
        mapView.zoomLevel = raceTrack.mapZoom
        mapView.setCenterCoordinate(loc, animated: false)

        mapView.addOverlays(mapStartCircles)
        mapView.addOverlays(mapStopCircles)
    }

    func addMe() {
        Me.sharedInstance.fetchAvatar { image in
            self.didPlayerAdded(avatar: image, name: "我", score: RmScore(), sender: self.blueButton)
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
        let addViewController = R.storyboard.mine.add_player_popover!
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 258)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }

    @IBAction func didPlayBack(sender: UIButton) {
        if !recordMode {
            stopTime = max(max(blueDataList.last?.t ?? 0, yellowDataList.last?.t ?? 0), purpleDataList.last?.t ?? 0)
            play()
        }
    }

    @IBAction func didSetStart(sender: UIButton) {
//        mapView.removeOverlay(mapStartCircle)
//        mapStartCircle = MACircle(centerCoordinate: DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D.Zero, radius: 10)
//        mapView.addOverlay(mapStartCircle)
//
//        try! realm.write {
//            self.raceTrack.startLat = self.mapStartCircle.coordinate.latitude
//            self.raceTrack.startLong = self.mapStartCircle.coordinate.longitude
//            self.raceTrack.startAlt = DeviceDataService.sharedInstance.rx_location.value?.altitude ?? 0
//            self.raceTrack.cycle = true
//        }
//        self.view.makeToast(message: "已设定起点")
    }

    @IBAction func didSetStop(sender: UIButton) {
//        if let loc = DeviceDataService.sharedInstance.rx_location.value {
//            let startLoc = CLLocation(latitude: raceTrack.startLat, longitude: raceTrack.startLong)
//            if loc.distanceFromLocation(startLoc) < 100 && abs(loc.altitude - raceTrack.startAlt) < 50 {
//                self.view.makeToast(message: "已设定起点与终点相同")
//                return
//            }
//            mapView.removeOverlay(mapStopCircle)
//            mapStopCircle = MACircle(centerCoordinate: DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D.Zero, radius: 10)
//            mapView.addOverlay(mapStopCircle)
//
//            try! realm.write {
//                self.raceTrack.stopLat = self.mapStopCircle.coordinate.latitude
//                self.raceTrack.stopLong = self.mapStopCircle.coordinate.longitude
//                self.raceTrack.stopAlt = DeviceDataService.sharedInstance.rx_location.value?.altitude ?? 0
//                self.raceTrack.cycle = false
//            }
//            self.view.makeToast(message: "已设定终点")
//        }
    }

    @IBAction func didMarkMap(sender: UIButton) {
        try! realm.write {
            self.raceTrack.mapCenter?.latitude = self.mapView.centerCoordinate.latitude
            self.raceTrack.mapCenter?.longitude = self.mapView.centerCoordinate.longitude
            self.raceTrack.mapZoom = self.mapView.zoomLevel
        }
    }
}

extension MatchViewController: AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String, score: RmScore, sender: UIButton?) {
        if let pressedButton = sender {
            pressedButton.setBackgroundImage(avatar, forState: .Normal)
            pressedButton.layer.cornerRadius = 20
            pressedButton.clipsToBounds = true
            if pressedButton == blueButton && name == "我" {
                return
            }

            switch pressedButton {
            case self.purpleButton:
                self.purpleDataList = score.data
                self.mapView.removeAnnotation(self.purpleAnnotation)
                self.purpleTitle.text = name
                self.purpleAnnotation = MAPointAnnotation()
                if let first = score.data.first {
                    self.purpleAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
                self.mapView.addAnnotation(self.purpleAnnotation)
                break
            case self.yellowButton:
                self.yellowDataList = score.data
                self.mapView.removeAnnotation(self.yellowAnnotation)
                self.yellowTitle.text = name
                self.yellowAnnotation = MAPointAnnotation()
                if let first = score.data.first {
                    self.yellowAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
                self.mapView.addAnnotation(self.yellowAnnotation)
                break
            case self.blueButton:
                self.blueDataList = score.data
                self.mapView.removeAnnotation(self.blueAnnotation)
                self.blueTitle.text = name
                self.blueAnnotation = MAPointAnnotation()
                if let first = score.data.first {
                    self.blueAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
                self.mapView.addAnnotation(self.blueAnnotation)
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
        return nil
    }

    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MACircle) {
            let circleView = MACircleView(overlay: overlay)
            circleView.lineWidth = 1
            circleView.strokeColor = UIColor.blackColor()
            if let circle = overlay as? MACircle {
                if mapStartCircles.contains(circle) {
                    circleView.fillColor = UIColor.greenColor()
                }
                if mapStopCircles.contains(circle) {
                    circleView.fillColor = UIColor.redColor()
                }
            }
            return circleView
        }
        return nil
    }
}

extension MatchViewController {
    override func animationDidStart(anim: CAAnimation) {
        self.mapView.zoomEnabled = false
        self.mapView.scrollEnabled = false
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.mapView.zoomEnabled = true
        self.mapView.scrollEnabled = true
    }
}
