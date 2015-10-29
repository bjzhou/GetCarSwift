//
//  MapViewModel.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


typealias AnnotationTuple = ([CustomMAPointAnnotation], [CustomMAPointAnnotation])

struct MapViewModel {

    var annotations: [String:CustomMAPointAnnotation] = [:]

    mutating func updateNearby() -> Observable<AnnotationTuple> {
        return timer(0, 10, MainScheduler.sharedInstance).map { _ in
            Nearby.map(accelerate: (DeviceDataService.sharedInstance.rx_acceleration.value?.y ?? 0) * 10, speed: DeviceDataService.sharedInstance.rx_location.value?.speed ?? 0)
        }
        .concat()
        .map { result in
            var newAnnotations: [CustomMAPointAnnotation] = []
            var oldAnnotations: [CustomMAPointAnnotation] = []
            if let nearbys = result.dataArray {
                let nearbyTitles = nearbys.map { nearby in
                    return nearby.nickname
                }
                oldAnnotations = self.annotations.filter { !nearbyTitles.contains($0.0) }.map { $0.1 }
                newAnnotations = nearbys.filter { nearby in
                    if let annotation = self.annotations[nearby.nickname] {
                        self.updateAnnotation(annotation, nearby: nearby)
                        return false
                    }
                    return true
                    }.map { nearby in
                        let pointAnnotation = CustomMAPointAnnotation()
                        self.annotations[nearby.nickname] = pointAnnotation
                        self.updateAnnotation(pointAnnotation, nearby: nearby)
                        return pointAnnotation
                }
            }
            return (oldAnnotations, newAnnotations)
        }
    }

    func updateAnnotation(pointAnnotation: CustomMAPointAnnotation, nearby: Nearby) {
        let newCoordinate = CLLocation(latitude: nearby.lati, longitude: nearby.longt)
        pointAnnotation.coordinate = newCoordinate.coordinate
        pointAnnotation.title = nearby.nickname
        pointAnnotation.image = UIImage(named: getCarIconName(nearby.sex, color: nearby.car_head_bg, icon: nearby.car_head_id))?.scaleImage(scale: 0.5)
        if let dis = DeviceDataService.sharedInstance.rx_location.value?.distanceFromLocation(newCoordinate) {
            if dis >= 1000 {
                pointAnnotation.subtitle = "距离\(Int(dis/1000))千米"
            } else {
                pointAnnotation.subtitle = "距离\(Int(dis))米"
            }
        }
    }

}
