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

    var zoomLevel: CGFloat = 3
    var centerCoordinate = CLLocationCoordinate2D(latitude: 35, longitude: 106)

    override func viewDidLoad() {
        super.viewDidLoad()

        initMapView()

        mapViewModel = MapViewModel()
    }

    func initMapView() {
        mapView.layoutIfNeeded()
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPoint(x: 8, y: 44)
        mapView.zoomLevel = zoomLevel
        mapView.setCenter(centerCoordinate, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(mapViewModel.loadTracks())
    }

    @IBAction func didLayerChanged(_ sender: UIButton) {
        if mapView.mapType == MAMapType.standard {
            mapView.mapType = MAMapType.satellite
        } else {
            mapView.mapType = MAMapType.standard
        }
    }
}

extension MapViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        guard let annotation = annotation as? RaceTrackAnnotation else {
            return nil
        }

        let pointReuseIndetifier = "pointReuseIndetifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
        if annotationView == nil {
            annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            annotationView?.layer.shadowOffset = CGSize(width: 1, height: 2)
            annotationView?.layer.shadowRadius = 2
            annotationView?.layer.shadowOpacity = 1
        }
        annotationView?.canShowCallout = false
        annotationView?.isDraggable = false

        annotationView?.image = annotation.raceTrack.isDeveloped ? R.image.red_flag() : R.image.gray_flag()

        return annotationView
    }

    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        guard let circle = overlay as? MACircle else {
            return nil
        }

        let circleView = MACircleRenderer(circle: circle)
        circleView?.strokeColor = UIColor.black
        circleView?.lineWidth = 1
        circleView?.fillColor = UIColor.yellow
        return circleView
    }

    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        guard let annotation = view.annotation as? RaceTrackAnnotation else {
            return
        }

        mapView.deselectAnnotation(annotation, animated: true)

        mapView.centerCoordinate = annotation.coordinate
        mapView.setZoomLevel(annotation.raceTrack.mapZoom, animated: true)

        let mapAlertVC = R.storyboard.gkbox.map_alert()
        mapAlertVC?.raceTrack = annotation.raceTrack
        mapAlertVC?.view.frame.size = CGSize(width: self.view.frame.width, height: 128)
        let popopVC = PopupViewController(rootViewController: mapAlertVC!, popupType: .ActionSheet, sender: self)
        self.tabBarController?.present(popopVC, animated: false, completion: nil)
    }

    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        #if DEBUG
            print("[\(coordinate.latitude), \(coordinate.longitude), 0]")
            let circle = MACircle(center: coordinate, radius: 15)
            mapView.add(circle)
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
