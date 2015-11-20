//
//  MKMapView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/20.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    var zoomLevel: Double {
        get {
            return Double(log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1);
        }

        set(newZoomLevel) {
            setCenterCoordinate(self.centerCoordinate, zoomLevel: newZoomLevel, animated: false)
        }
    }

    func setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Double, animated: Bool) {
        let span = MKCoordinateSpanMake(0, 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256)
        setRegion(MKCoordinateRegionMake(centerCoordinate, span), animated: animated)
    }
}