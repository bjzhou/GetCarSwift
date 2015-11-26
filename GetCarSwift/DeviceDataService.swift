//
//  DeviceDataService.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import CoreMotion
import RxSwift

struct GKAcceleration {
    private var latest10 = [CMAcceleration]()

    var last = CMAcceleration()

    mutating func append(value: CMAcceleration) {
        if latest10.count >= 10 {
            latest10.removeFirst()
        }
        latest10.append(value)
        last = value
    }

    func averageA() -> Double {
        let count = Double(latest10.count)
        let acce = latest10.reduce((0.0, 0.0, 0.0), combine: { ($0.0 + $1.x / count, $0.1 + $1.y / count, $0.2 + $1.z / count) })
        return sqrt(acce.0 * acce.0 + acce.1 * acce.1 * acce.2 * acce.2) * 9.81
    }
}

class DeviceDataService: NSObject {
    static let sharedInstance = DeviceDataService()

    let disposeBag = DisposeBag()

    let motionManager = CMMotionManager()
    let altitudeManager = CMAltimeter()
    let locationManager = AMapLocationManager()
    var searchApi = AMapSearchAPI()

    var districtService: Disposable?

    var rxAcceleration: Variable<GKAcceleration> = Variable(GKAcceleration())
    var rxAltitude: Variable<CMAltitudeData?> = Variable(nil)
    var rxLocation: Variable<CLLocation?> = Variable(nil)
    var rxDistrict = Variable("正在获取位置信息")

    override init() {
        super.init()

        searchApi.delegate = self

        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) in
                if let validData = data {
                    self.rxAcceleration.value.append(validData.userAcceleration)
                }
            })
        }

        if CMAltimeter.isRelativeAltitudeAvailable() {
            altitudeManager.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) in
                if let validData = data {
                    self.rxAltitude.value = validData
                }
            })
        }

        timer(0, 60, MainScheduler.sharedInstance).subscribeNext { _ in
            self.districtService = self.rxLocation.subscribeNext { location in
                guard let location = location else {
                    return
                }
                let regeoRequest = AMapReGeocodeSearchRequest()
                regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
                regeoRequest.requireExtension = true

                self.searchApi.AMapReGoecodeSearch(regeoRequest)
            }
            }.addDisposableTo(disposeBag)
    }
}

extension DeviceDataService: AMapSearchDelegate {
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        let city = response.regeocode.addressComponent.city == nil ? response.regeocode.addressComponent.district : response.regeocode.addressComponent.city
        self.rxDistrict.value = "\(response.regeocode.addressComponent.province)\(city)"
        districtService?.dispose()
    }
}

extension DeviceDataService: AMapLocationManagerDelegate {
    func amapLocationManager(manager: AMapLocationManager!, didUpdateLocation location: CLLocation!) {
        self.rxLocation.value = location
    }
}
