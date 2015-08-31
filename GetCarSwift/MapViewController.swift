//
//  MapViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var layerButton: UIButton!
    @IBOutlet weak var trafficButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MAMapView!

    var timer = NSTimer()
    var annotations: [MAPointAnnotation] = []

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
        GeoApi.map(accelerate: parent.a, speed: DataKeeper.sharedInstance.location?.speed ?? 0) { result in
            guard let json = result.data else {
                return
            }
            
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll()
            for (_, subJson) in json {
                let newCoordinate = CLLocation(latitude: subJson["lati"].doubleValue, longitude: subJson["longt"].doubleValue)
                let pointAnnotation = MAPointAnnotation()
                pointAnnotation.coordinate = newCoordinate.coordinate
                pointAnnotation.title = subJson["nickname"].stringValue
                if let dis = DataKeeper.sharedInstance.location?.distanceFromLocation(newCoordinate) {
                    if dis >= 1000 {
                        pointAnnotation.subtitle = "距离\(Int(dis/1000))千米"
                    } else {
                        pointAnnotation.subtitle = "距离\(Int(dis))米"
                    }
                    self.annotations.append(pointAnnotation)
                }
            }
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    @IBAction func locationButtonAction(sender: UIButton) {
        mapView.userTrackingMode = MAUserTrackingModeFollow
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

extension MapViewController: MAMapViewDelegate {
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKindOfClass(MAUserLocation) {
            let userLocationStyleReuseIndetifier = "userLocationStyleReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(userLocationStyleReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: userLocationStyleReuseIndetifier)
            }
            let sex = NSUserDefaults.standardUserDefaults().integerForKey("sex")
            let color = NSUserDefaults.standardUserDefaults().integerForKey("color")
            let icon = NSUserDefaults.standardUserDefaults().integerForKey("icon")
            annotationView.image = UIImage(named: getCarIconName(sex, color: color, icon: icon))
            
            return annotationView
        }
        
        if annotation.isKindOfClass(MAPointAnnotation) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier) as? MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier) as MAPinAnnotationView
            }
            annotationView!.canShowCallout = true
            annotationView!.animatesDrop = false
            annotationView!.draggable = false
            annotationView!.pinColor = MAPinAnnotationColor.Purple
            
            annotationView!.image = UIImage(named: "白2")
            
            return annotationView;
        }
        return nil;
    }
    
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!) {
        DataKeeper.sharedInstance.location = userLocation.location
    }
}
