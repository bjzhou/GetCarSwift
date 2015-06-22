//
//  MapViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

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
        checkNewVersion()
    }
    
    func checkNewVersion() {
        Alamofire.request(.GET, URLString: FIR_URL_VERSION_CHECK)
            .responseJSON { (req, res, json, err) in
                if err != nil {
                    return
                }
                var json = JSON(json!)
                if let latest = json["version"].string, latestShort = json["versionShort"].string {
                    if VERSION != latest {
                        let alert = UIAlertController(title: "更新", message: "当前版本：" + VERSION_SHORT! + "\n最新版本：" + latestShort + "\n版本信息：" + json["changelog"].stringValue + "\n\n是否下载安装最新版本？", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "安装", style: .Default, handler: { (action) in
                            if let update_url = json["update_url"].string {
                                UIApplication.sharedApplication().openURL(NSURL(string: update_url)!)
                            }
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    func initMapView() {
        mapView.delegate = self
        mapView.userTrackingMode = MAUserTrackingModeFollow
        mapView.showsCompass = false
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
        if mapView.mapType == UInt(MAMapTypeStandard) {
            mapView.mapType = UInt(MAMapTypeSatellite)
        } else {
            mapView.mapType = UInt(MAMapTypeStandard)
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
            annotationView!.pinColor = UInt(MAPinAnnotationColorPurple)
            
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
