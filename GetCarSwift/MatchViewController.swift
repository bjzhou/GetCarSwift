//
//  MatchViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/24.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    @IBOutlet weak var mapView: MAMapView!

    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet weak var purpleTitle: UILabel!
    @IBOutlet weak var yellowTitle: UILabel!
    @IBOutlet weak var blueTitle: UILabel!

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
    
    @IBAction func locationButtonAction(sender: UIButton) {
        mapView.userTrackingMode = MAUserTrackingModeFollow
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

extension MatchViewController: MAMapViewDelegate {
    
}
