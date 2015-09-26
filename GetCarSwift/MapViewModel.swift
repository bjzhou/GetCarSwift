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

struct MapViewModel {

    func updateNearby() -> Observable<Array<CustomMAPointAnnotation>> {
        return timer(0, 5, MainScheduler.sharedInstance).map { _ in
            Nearby.map(accelerate: (DeviceDataService.sharedInstance.rx_acceleration.value?.y ?? 0) * 10, speed: DeviceDataService.sharedInstance.rx_location.value?.speed ?? 0)
        }
        .concat()
        .map { result in
            var annotations: [CustomMAPointAnnotation] = []
            if let nearbys = result.dataArray {
                for nearby in nearbys {
                    let newCoordinate = CLLocation(latitude: nearby.lati, longitude: nearby.longt)
                    let pointAnnotation = CustomMAPointAnnotation()
                    pointAnnotation.coordinate = newCoordinate.coordinate
                    pointAnnotation.title = nearby.nickname
                    pointAnnotation.image = UIImage(named: getCarIconName(nearby.sex, color: nearby.car_head_bg, icon: nearby.car_head_id))!
                    if let dis = DeviceDataService.sharedInstance.rx_location.value?.distanceFromLocation(newCoordinate) {
                        if dis >= 1000 {
                            pointAnnotation.subtitle = "距离\(Int(dis/1000))千米"
                        } else {
                            pointAnnotation.subtitle = "距离\(Int(dis))米"
                        }
                        annotations.append(pointAnnotation)
                    }
                }
            }
            return annotations
        }
    }

}
