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

typealias Score = [Double:[String:Double]]

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

    var newDataList: Score = [:]

    var purpleDataList: Score = [:]
    var yellowDataList: Score = [:]
    var blueDataList: Score = [:]

    var _10msTimer: Disposable?
    var _100msTimer: Disposable?
    var locationDisposable: Disposable?

    var prevKeyPurple = 0.0
    var prevKeyYellow = 0.0
    var prevKeyBlue = 0.0

    var lapDir = File(path: "lap")

    override func viewDidLoad() {
        self.title = mapTitle

        lapDir.mkdir()

        initMapView()
        if recordMode {
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
                    if MACircleContainsCoordinate(location.coordinate, self.mapStartCircle.coordinate, 10) {
                        if self.playing && !self.ready {
                            self.stop()
                            self.stateLabel.text = "已结束"
                        }
                        self.playing = false
                        self.ready = true
                        self.stateLabel.text = "已就绪"
                    } else {
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
        }
        _10msTimer?.dispose()
        _100msTimer?.dispose()

        _100msTimer = timer(0, 0.1, MainScheduler.sharedInstance).subscribeNext { ti in
            let s = Double(ti)/10
            if self.recordMode {
                var point: [String:Double] = [:]
                point["lat"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.latitude ?? 0
                point["long"] = DeviceDataService.sharedInstance.rx_location.value?.coordinate.longitude ?? 0
                let speed = DeviceDataService.sharedInstance.rx_location.value?.speed
                point["speed"] = round((speed < 0 ? 0 : speed ?? 0) * 3.6 * 1000) / 1000
                point["accelarate"] = round(abs(DeviceDataService.sharedInstance.rx_acceleration.value?.y ?? 0) * 100) / 10
                if self.newDataList[self.prevKeyBlue]?["lat"] != point["lat"] || self.newDataList[self.prevKeyBlue]?["long"] != point["long"] {
                    self.newDataList[s] = point
                    self.prevKeyBlue = s
                }

                self.blueSpeed.text = String(point["speed"]!)
                self.blueAcce.text = String(point["accelarate"]!)
            } else {
                if let data = self.blueDataList[s] where (data["lat"] != self.blueDataList[self.prevKeyBlue]?["lat"] || data["long"] != self.blueDataList[self.prevKeyBlue]?["long"]) {
                    let duration = s - self.prevKeyBlue + 0.01
                    let view = self.mapView.viewForAnnotation(self.blueAnnotation)
                    UIView.transitionWithView(view, duration: duration, options: [.BeginFromCurrentState, .CurveLinear], animations: {
                        self.blueAnnotation?.coordinate = CLLocationCoordinate2D(latitude: data["lat"]!, longitude: data["long"]!)
                        }, completion: { result in
                            self.prevKeyBlue = s
                    })
                    self.blueSpeed.text = "\(data["speed"]!)"
                    self.blueAcce.text = "\(data["accelarate"]!)"
                }
                if let data = self.yellowDataList[s] where (data["lat"] != self.yellowDataList[self.prevKeyYellow]?["lat"] || data["long"] != self.yellowDataList[self.prevKeyYellow]?["long"]) {
                    let duration = s - self.prevKeyYellow + 0.01
                    let view = self.mapView.viewForAnnotation(self.yellowAnnotation)
                    UIView.transitionWithView(view, duration: duration, options: [.BeginFromCurrentState, .CurveLinear], animations: {
                        self.yellowAnnotation?.coordinate = CLLocationCoordinate2D(latitude: data["lat"]!, longitude: data["long"]!)
                        }, completion: { result in
                            self.prevKeyYellow = s
                    })
                    self.yellowSpeed.text = "\(data["speed"]!)"
                    self.yellowAcce.text = "\(data["accelarate"]!)"
                }
                if let data = self.purpleDataList[s] where (data["lat"] != self.purpleDataList[self.prevKeyPurple]?["lat"] || data["long"] != self.purpleDataList[self.prevKeyPurple]?["long"]) {
                    let duration = s - self.prevKeyPurple + 0.01
                    let view = self.mapView.viewForAnnotation(self.purpleAnnotation)
                    UIView.transitionWithView(view, duration: duration, options: [.BeginFromCurrentState, .CurveLinear], animations: {
                        self.purpleAnnotation?.coordinate = CLLocationCoordinate2D(latitude: data["lat"]!, longitude: data["long"]!)
                        }, completion: { result in
                            self.prevKeyPurple = s
                    })
                    self.purpleSpeed.text = "\(data["speed"]!)"
                    self.purpleAcce.text = "\(data["accelarate"]!)"
                }

                if s > self.stopTime {
                    self.stop()
                }
            }
        }
        _10msTimer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let tms = t % 100
            let s = t / 100 % 60
            let m = t / 100 / 60
            self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

            if self.recordMode {
                self.blueAnnotation?.coordinate = DeviceDataService.sharedInstance.rx_location.value?.coordinate ?? CLLocationCoordinate2D.Zero
            }
        }
        //testAnim()
    }

    func stop() {
        _10msTimer?.dispose()
        _100msTimer?.dispose()
        timeLabel.text = "00:00.00"
        blueSpeed.text = "0.0"
        blueAcce.text = "0.0"
        if recordMode {
            let alert = UIAlertController(title: nil, message: "正在保存...", preferredStyle: .Alert)
            presentViewController(alert, animated: true, completion: nil);
            {
                let testFiles: [String] = try! self.lapDir.list().filter { $0.hasPrefix("test") }
                let file = File(path: "test\(testFiles.count)")
                return NSKeyedArchiver.archiveRootObject(self.newDataList, toFile: file.path)
                } ~> { (result: Bool) in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.view.makeToast(message: result ? "保存成功" : "保存失败")
            }
        }
    }

    func testAnim() {

        let points: [CGPoint] = self.blueDataList.keys.sort().map { key in
            let loc = CLLocationCoordinate2D(latitude: self.blueDataList[key]!["lat"] ?? 0, longitude: self.blueDataList[key]!["long"] ?? 0)
            return self.mapView.convertCoordinate(loc, toPointToView: self.mapView)
        }
        let path = CGPathCreateMutable()
        CGPathAddLines(path, nil, points, points.count)
        CGPathCloseSubpath(path)

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = blueDataList.keys.sort().last ?? 0
        anim.fromValue = 0
        anim.toValue = 1
        anim.delegate = self

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 4
        shapeLayer.strokeColor = UIColor.blueColor().CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor

        shapeLayer.path = path
        self.mapView.layer.insertSublayer(shapeLayer, atIndex: 1)
        shapeLayer.addAnimation(anim, forKey: "shape")
    }

    func testAnim2() {

        let points: [CGPoint] = self.blueDataList.keys.sort().map { key in
            let loc = CLLocationCoordinate2D(latitude: self.blueDataList[key]!["lat"] ?? 0, longitude: self.blueDataList[key]!["long"] ?? 0)
            return self.mapView.convertCoordinate(loc, toPointToView: self.mapView)
        }
        let path = CGPathCreateMutable()
        CGPathAddLines(path, nil, points, points.count)
        CGPathCloseSubpath(path)

        let lastTime = blueDataList.keys.sort().last ?? 0
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.duration = lastTime
        //anim.path = path
        anim.values = points.map { NSValue(CGPoint: CGPointMake($0.x - points[0].x, $0.y - points[0].y)) }
        anim.calculationMode = kCAAnimationPaced
        anim.rotationMode = kCAAnimationRotateAuto
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.additive = true
        anim.delegate = self

        let view = self.mapView.viewForAnnotation(self.blueAnnotation)
        view.layer.addAnimation(anim, forKey: "annotation")
        //self.blueAnnotation?.coordinate = CLLocationCoordinate2D(latitude: self.blueDataList[lastTime]!["lat"] ?? 0, longitude: self.blueDataList[lastTime]!["long"] ?? 0)
    }

    override func viewDidDisappear(animated: Bool) {
        _10msTimer?.dispose()
        _100msTimer?.dispose()
        locationDisposable?.dispose()
        UIApplication.sharedApplication().idleTimerDisabled = false
    }

    func initMapView() {
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 8)

        if recordMode {
            mapView.showsUserLocation = true
        }

        if let map = NSUserDefaults.standardUserDefaults().valueForKey(mapTitle) {
            let loc = CLLocationCoordinate2D(latitude: map["center_lat"] as! Double, longitude: map["center_lng"] as! Double)
            mapStartCircle = MACircle(centerCoordinate: CLLocationCoordinate2D(latitude: map["start_lat"] as! Double, longitude: map["start_lng"] as! Double), radius: 10)
            mapView.setCenterCoordinate(loc, animated: false)
            mapView.zoomLevel = map["zoom"] as! Double
        } else {
            mapView.setCenterCoordinate(mapCenter, animated: false)
            mapView.zoomLevel = 16.5
        }

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
        let addViewController = R.storyboard.mine.add_player_popover!
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 258)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
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
            stopTime = max(max(blueDataList.keys.sort().last ?? 0, yellowDataList.keys.sort().last ?? 0), purpleDataList.keys.sort().last ?? 0)
            play()
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

            let alert = UIAlertController(title: nil, message: "正在读取...", preferredStyle: .Alert)
            presentViewController(alert, animated: true, completion: nil);
            {
                let dataList = NSKeyedUnarchiver.unarchiveObjectWithFile(try! File(dir: self.lapDir, name: name).path) as? Score
                return dataList
                } ~> { (dataList: Score?) in
                    if let dataList = dataList {
                        switch pressedButton {
                        case self.purpleButton:
                            self.purpleDataList = dataList
                            self.mapView.removeAnnotation(self.purpleAnnotation)
                            self.purpleTitle.text = name
                            self.purpleAnnotation = MAPointAnnotation()
                            if let first = dataList[dataList.keys.sort().first ?? 0] {
                                self.purpleAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first["lat"] ?? 0, longitude: first["long"] ?? 0)
                            }
                            self.mapView.addAnnotation(self.purpleAnnotation)
                            break
                        case self.yellowButton:
                            self.yellowDataList = dataList
                            self.mapView.removeAnnotation(self.yellowAnnotation)
                            self.yellowTitle.text = name
                            self.yellowAnnotation = MAPointAnnotation()
                            if let first = dataList[dataList.keys.sort().first ?? 0] {
                                self.yellowAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first["lat"] ?? 0, longitude: first["long"] ?? 0)
                            }
                            self.mapView.addAnnotation(self.yellowAnnotation)
                            break
                        case self.blueButton:
                            self.blueDataList = dataList
                            self.mapView.removeAnnotation(self.blueAnnotation)
                            self.blueTitle.text = name
                            self.blueAnnotation = MAPointAnnotation()
                            if let first = dataList[dataList.keys.sort().first ?? 0] {
                                self.blueAnnotation!.coordinate = CLLocationCoordinate2D(latitude: first["lat"] ?? 0, longitude: first["long"] ?? 0)
                            }
                            self.mapView.addAnnotation(self.blueAnnotation)
                            break
                        default:
                            break
                        }
                    }
                    alert.dismissViewControllerAnimated(true, completion: nil)
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

extension MatchViewController {
    override func animationDidStart(anim: CAAnimation) {
        print(anim)
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        print(anim, flag)
    }
}
