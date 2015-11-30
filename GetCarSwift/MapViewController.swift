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
    @IBOutlet weak var bottomViewPos: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackAddressButton: UIButton!
    @IBOutlet weak var gotoTrackButton: UIButton!
    @IBOutlet weak var trackIntroButton: UIButton!

    var mapViewModel: MapViewModel!

    var gotoTrackAction: Disposable?
    var trackAddressAction: Disposable?
    var trackIntroAction: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()

        initMapView()

        mapViewModel = MapViewModel()
        mapView.addAnnotations(mapViewModel.loadTracks())

        closeButton.rx_tap.subscribeNext {
            self.bottomViewPos.constant = -128
            UIView.animateWithDuration(0.3) {
                self.view.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)
    }

    func initMapView() {
        mapView.layoutIfNeeded()
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.scaleOrigin = CGPointMake(8, 44)
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
            if bottomViewPos.constant == 0 {
                bottomViewPos.constant = -128
                UIView.animateWithDuration(0.3, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { _ in
                        self.trackTitleLabel.text = annotation.title
                        self.trackAddressButton.setTitle(annotation.subtitle, forState: .Normal)
                        self.bottomViewPos.constant = 0
                        UIView.animateWithDuration(0.3) {
                            self.view.layoutIfNeeded()
                        }
                })
            } else {
                self.trackTitleLabel.text = annotation.title
                self.trackAddressButton.setTitle(annotation.subtitle, forState: .Normal)
                self.bottomViewPos.constant = 0
                UIView.animateWithDuration(0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            gotoTrackAction?.dispose()
            trackAddressAction?.dispose()
            trackIntroAction?.dispose()
            gotoTrackButton.enabled = annotation.raceTrack.isDeveloped
            gotoTrackAction = gotoTrackButton.rx_tap.subscribeNext {
                let vc = R.storyboard.gkbox.track_timer
                vc?.raceTrack = annotation.raceTrack
                self.showViewController(vc!)
            }
            trackAddressAction = trackAddressButton.rx_tap.subscribeNext {
                let gaodeUrl = "iosamap://path?sourceApplication=\(productName!)&sid=BGVIS1&did=BGVIS2&dname=\(annotation.title.encodedUrlString)&dev=0&m=0&t=0"
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: gaodeUrl)!) {
                    UIApplication.sharedApplication().openURL(NSURL(string: gaodeUrl)!)
                } else {
                    let origin = "我的位置".encodedUrlString
                    let src = "\(bundleId!)|\(productName!)".encodedUrlString
                    let baiduUrl = "baidumap://map/direction?origin=\(origin)&destination=\(annotation.title.encodedUrlString)&mode=driving&src=\(src)"
                    if UIApplication.sharedApplication().canOpenURL(NSURL(string: baiduUrl)!) {
                        UIApplication.sharedApplication().openURL(NSURL(string: baiduUrl)!)
                    } else {
                        UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?daddr=\(annotation.title.encodedUrlString)&dirflg=d&t=m")!)
                    }
                }
            }
            trackIntroAction = trackIntroButton.rx_tap.subscribeNext {
                let vc = R.storyboard.gkbox.track_intro
                vc?.raceTrack = annotation.raceTrack
                self.showViewController(vc!)
            }
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
