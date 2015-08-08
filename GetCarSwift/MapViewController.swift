//
//  MapViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, MAMapViewDelegate {
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var layerButton: UIButton!
    @IBOutlet weak var trafficButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MAMapView!

    var newCoordinate: CLLocationCoordinate2D?

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
    }
    
    override func viewDidAppear(animated: Bool) {
        mapView.showsUserLocation = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        mapView.showsUserLocation = false
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
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier) as?MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier) as MAPinAnnotationView
            }
            annotationView!.canShowCallout = true       //设置气泡可以弹出，默认为NO
            annotationView!.animatesDrop = true        //设置标注动画显示，默认为NO
            annotationView!.draggable = true        //设置标注可以拖动，默认为NO
            annotationView!.pinColor = MAPinAnnotationColor.Purple
            
            annotationView!.image = UIImage(named: "白2")

            return annotationView;
        }
        return nil;
    }
    
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if (newCoordinate == nil) {
            newCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude + 0.001)
            let pointAnnotation = MAPointAnnotation()
            pointAnnotation.coordinate = newCoordinate!
            pointAnnotation.title = "测试"
            pointAnnotation.subtitle = "测试测试"
            
            mapView.addAnnotation(pointAnnotation)
        }
    }

}
