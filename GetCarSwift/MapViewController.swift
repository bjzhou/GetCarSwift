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

    @IBOutlet weak var mapView: MAMapView!

    var mapViewModel: MapViewModel!

    var alertWindow = UIWindow()

    var closeAction: Disposable?
    var gotoTrackAction: Disposable?
    var trackAddressAction: Disposable?
    var trackIntroAction: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()

        initMapView()

        mapViewModel = MapViewModel()
        mapView.addAnnotations(mapViewModel.loadTracks())
    }

    func initMapView() {
        mapView.layoutIfNeeded()
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 44)
        mapView.zoomLevel = 3
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 35, longitude: 106), animated: false)
    }

    @IBAction func didLayerChanged(sender: UIButton) {
        if mapView.mapType == MAMapType.Standard {
            mapView.mapType = MAMapType.Satellite
        } else {
            mapView.mapType = MAMapType.Standard
        }
    }
}

extension MapViewController: MAMapViewDelegate {
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if let annotation = annotation as? RaceTrackAnnotation {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pointReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
                annotationView.layer.shadowOffset = CGSize(width: 1, height: 2)
                annotationView.layer.shadowRadius = 2
                annotationView.layer.shadowOpacity = 1
            }
            annotationView?.canShowCallout = false
            annotationView?.draggable = false

            annotationView?.image = annotation.raceTrack.isDeveloped ? R.image.red_flag : R.image.gray_flag

            return annotationView
        }
        return nil
    }

    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if let circle = overlay as? MACircle {
            let circleView = MACircleView(circle: circle)
            circleView.strokeColor = UIColor.blackColor()
            circleView.lineWidth = 1
            circleView.fillColor = UIColor.yellowColor()
            return circleView
        }
        return nil
    }

    func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        if let annotation = view.annotation as? RaceTrackAnnotation {
            mapView.deselectAnnotation(annotation, animated: true)

            let mapAlertVC = R.storyboard.gkbox.map_alert
            mapAlertVC?.raceTrack = annotation.raceTrack
            mapAlertVC?.view.frame.size = CGSize(width: self.view.frame.width, height: 128)
            let popopVC = PopupViewController(rootViewController: mapAlertVC!, popupType: .ActionSheet, sender: self)
            self.tabBarController?.presentViewController(popopVC, animated: false, completion: nil)
        }
    }

    func mapView(mapView: MAMapView!, didSingleTappedAtCoordinate coordinate: CLLocationCoordinate2D) {
        #if DEBUG
            print(coordinate)
        #endif
    }
}

class RaceTrackAnnotation: MAPointAnnotation {
    var raceTrack: RmRaceTrack
    init(raceTrack: RmRaceTrack) {
        self.raceTrack = raceTrack
        super.init()
    }
}
