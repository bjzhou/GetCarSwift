//
//  MapViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class MapViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var layerButton: UIButton!
    @IBOutlet weak var trafficButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MAMapView!

    var locationImage: UIImage?

    var annotations: [CustomMAPointAnnotation] = []

    var timer: Disposable?
    var mapViewModel: MapViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        initMapView()

        mapViewModel = MapViewModel()

        User.rx_me
            .observeOn(MainScheduler.sharedInstance)
            .subscribeNext { me in
            self.setLocationImage()
        }.addDisposableTo(disposeBag)

        setLocationImage()
    }

    func setLocationImage() {
        let color = Me.sharedInstance.carHeadBg
        let icon = Me.sharedInstance.carHeadId
        locationImage = UIImage(named: getCarIconName(Me.sharedInstance.sex, color: color, icon: icon))?.scaleImage(scale: 0.5)
        mapView.showsUserLocation = false
        mapView.showsUserLocation = true
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
        timer?.dispose()
        timer = mapViewModel.updateNearby().subscribeNext { (old, new) in
            self.mapView.removeAnnotations(old)
            self.mapView.addAnnotations(new)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        timer?.dispose()
    }

    @IBAction func locationButtonAction(sender: UIButton) {
        mapView.userTrackingMode = .Follow
        mapView.setZoomLevel(17, animated: true)
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
            annotationView.image = locationImage
            annotationView.canShowCallout = true

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
}

public class CustomMAPointAnnotation: MAPointAnnotation {
    public var image: UIImage?
    override init() {
        super.init()
    }
}
