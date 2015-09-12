//
//  MapViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import CoreMotion

class MapViewController: UIViewController {

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var layerButton: UIButton!
    @IBOutlet weak var trafficButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MAMapView!


    let motionManager = CMMotionManager()
    let altitudeManager = CMAltimeter()

    var locationImage: UIImage?

    var timer = NSTimer()
    var annotations: [CustomMAPointAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        DataKeeper.sharedInstance.addDelegate(self)

        initMapView()
        initMotion()
        initAltitude()

        setLocationImage()
    }

    func setLocationImage() {
        let color = DataKeeper.sharedInstance.carHeadBg
        let icon = DataKeeper.sharedInstance.carHeadId
        locationImage = UIImage(named: getCarIconName(DataKeeper.sharedInstance.sex, color, icon))
        mapView.showsUserLocation = false
        mapView.showsUserLocation = true
    }

    func initMotion() {
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue(), {
                        DataKeeper.sharedInstance.acceleration = validData.userAcceleration
                    })
                }
            })

        }
    }

    func initAltitude() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altitudeManager.startRelativeAltitudeUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
                if let validData = data {
                    dispatch_async(dispatch_get_main_queue(), {
                        DataKeeper.sharedInstance.altitude = validData
                    })
                }
            })
        }
    }

    func initMapView() {
        mapView.delegate = self
        mapView.userTrackingMode = .Follow
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 44)
        mapView.zoomLevel = 17
        mapView.showsUserLocation = true
    }

    override func viewDidAppear(animated: Bool) {
        if !animated {
            // abort when first added by swiftpages
            return
        }
        didTimerUpdate()
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("didTimerUpdate"), userInfo: nil, repeats: true)
    }

    override func viewDidDisappear(animated: Bool) {
        timer.invalidate()
    }

    func didTimerUpdate() {
        let parent = self.parentViewController as! TraceViewController
        GeoApi.sharedInstance.map(accelerate: parent.a, speed: DataKeeper.sharedInstance.location?.speed ?? 0) { result in
            if let json = result.data {
                self.mapView.removeAnnotations(self.annotations)
                self.annotations.removeAll()
                for (_, subJson) in json {
                    let newCoordinate = CLLocation(latitude: subJson["lati"].doubleValue, longitude: subJson["longt"].doubleValue)
                    let pointAnnotation = CustomMAPointAnnotation()
                    pointAnnotation.coordinate = newCoordinate.coordinate
                    pointAnnotation.title = subJson["nickname"].stringValue
                    pointAnnotation.image = UIImage(named: getCarIconName(subJson["sex"].intValue, subJson["car_head_bg"].intValue, subJson["car_head_id"].intValue))!
                    if let dis = DataKeeper.sharedInstance.location?.distanceFromLocation(newCoordinate) {
                        if dis >= 1000 {
                            pointAnnotation.subtitle = "距离\(Int(dis/1000))千米"
                        } else {
                            pointAnnotation.subtitle = "距离\(Int(dis))米"
                        }
                    }
                    self.annotations.append(pointAnnotation)
                }
                self.mapView.addAnnotations(self.annotations)
            }
        }
    }

    @IBAction func locationButtonAction(sender: UIButton) {
        mapView.userTrackingMode = .Follow
    }

    @IBAction func layerButtonAction(sender: UIButton) {
        if mapView.mapType == MAMapType.Standard {
            mapView.mapType = MAMapType.Satellite
        } else {
            mapView.mapType = MAMapType.Standard
        }
    }

    @IBAction func trafficButtonAction(sender: UIButton) {
        if sender.selected {
            mapView.showTraffic = false;
            sender.selected = false;
        } else {
            mapView.showTraffic = true;
            sender.selected = true;
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
}

extension MapViewController: DataKeeperDelegate {
    func didCarHeadBgUpdated(carHeadBg: Int) {
        setLocationImage()
    }

    func didCarHeadIdUpdated(carHeadId: Int) {
        setLocationImage()
    }

    func didSexUpdated(sex: Int) {
        setLocationImage()
    }
}

extension MapViewController: MAMapViewDelegate {
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKindOfClass(MAUserLocation) {
            let userLocationStyleReuseIndetifier = "userLocationStyleReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(userLocationStyleReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: userLocationStyleReuseIndetifier)
            }
            annotationView.image = locationImage

            return annotationView
        }

        if annotation.isKindOfClass(CustomMAPointAnnotation) {
            let annotation = annotation as! CustomMAPointAnnotation
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier) as? MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier) as MAPinAnnotationView
            }
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = false
            annotationView!.draggable = false

            annotationView!.image = annotation.image

            return annotationView;
        }
        return nil;
    }

    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!) {
        DataKeeper.sharedInstance.location = userLocation.location
    }
}

public class CustomMAPointAnnotation: MAPointAnnotation {
    public var image: UIImage = UIImage(named: "白2")!
    override init() {
        super.init()
    }
}
