//
//  MapViewModel.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class CarIconAnnotation: MAPointAnnotation {
    var image: UIImage?
}

typealias AnnotationTuple = ([CarIconAnnotation], [CarIconAnnotation])

struct MapViewModel {

    var annotations: [String: CarIconAnnotation] = [:]

    mutating func updateNearby() -> Observable<AnnotationTuple> {
        return Observable<Int>.timer(0, period: 10, scheduler: MainScheduler.instance).map { _ in
            Nearby.map()
        }
        .concat()
        .map { result in
            guard let nearbys = result.dataArray else {
                return ([], [])
            }

            var newAnnotations: [CarIconAnnotation] = []
            var oldAnnotations: [CarIconAnnotation] = []
            let nearbyTitles = nearbys.map { nearby in
                return nearby.nickname
            }
            DispatchQueue.main.sync {
                oldAnnotations = self.annotations.filter { !nearbyTitles.contains($0.key) }.map { $0.value }
                newAnnotations = nearbys.filter { nearby in
                    guard let annotation = self.annotations[nearby.nickname] else {
                        return true
                    }

                    self.updateAnnotation(annotation, nearby: nearby)
                    return false
                    }.map { nearby in
                        let pointAnnotation = CarIconAnnotation()
                        self.annotations[nearby.nickname] = pointAnnotation
                        self.updateAnnotation(pointAnnotation, nearby: nearby)
                        return pointAnnotation
                }
            }
            return (oldAnnotations, newAnnotations)
        }
    }

    func updateAnnotation(_ pointAnnotation: CarIconAnnotation, nearby: Nearby) {
        let newCoordinate = CLLocation(latitude: nearby.lati, longitude: nearby.longt)
        pointAnnotation.coordinate = newCoordinate.coordinate
        pointAnnotation.title = nearby.nickname
        pointAnnotation.image = UIImage(named: getCarIconName(nearby.sex, color: nearby.carHeadBg, icon: nearby.carHeadId))?.scaleImage(scale: 0.5)
        if let dis = DeviceDataService.sharedInstance.rxLocation.value?.distance(from: newCoordinate) {
            if dis >= 1000 {
                pointAnnotation.subtitle = "距离\(Int(dis/1000))千米"
            } else {
                pointAnnotation.subtitle = "距离\(Int(dis))米"
            }
        }
    }

    func loadTracks() -> [RaceTrackAnnotation] {
        return gRealm?.objects(RmRaceTrack.self).sorted(byProperty: "isDeveloped").flatMap { rt in
            guard let mapCenter = rt.mapCenter else {
                return nil
            }

            let anno = RaceTrackAnnotation(raceTrack: rt)
            anno.coordinate = CLLocationCoordinate2D(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
            anno.title = rt.name
            anno.subtitle = rt.address
            return anno
        } ?? []
    }

}
