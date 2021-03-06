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

    mutating func append(_ value: CMAcceleration) {
        if latest10.count >= 10 {
            latest10.removeFirst()
        }
        latest10.append(value)
        last = value
    }

    func averageA() -> Double {
        let count = Double(latest10.count)
        let acce = latest10.reduce((0.0, 0.0, 0.0), { ($0.0 + $1.x / count, $0.1 + $1.y / count, $0.2 + $1.z / count) })
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

        searchApi?.delegate = self

        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                if let validData = data {
                    self.rxAcceleration.value.append(validData.userAcceleration)
                }
            })
        }

        if CMAltimeter.isRelativeAltitudeAvailable() {
            altitudeManager.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                if let validData = data {
                    self.rxAltitude.value = validData
                }
            })
        }

        Observable<Int>.timer(0, period: 60, scheduler: MainScheduler.instance).subscribe(onNext: { _ in
            self.districtService = self.rxLocation.asObservable().subscribe(onNext: { location in
                guard let location = location else {
                    return
                }
                let regeoRequest = AMapReGeocodeSearchRequest()
                regeoRequest.location = AMapGeoPoint.location(withLatitude: CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
                regeoRequest.requireExtension = true

                self.searchApi?.aMapReGoecodeSearch(regeoRequest)
            })
            }).addDisposableTo(disposeBag)
    }
}

extension DeviceDataService: AMapSearchDelegate {
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if let province = response.regeocode.addressComponent.province, province != "" {
            let city = response.regeocode.addressComponent.city == "" ? response.regeocode.addressComponent.district : response.regeocode.addressComponent.city
            self.rxDistrict.value = "\(province)\(city)"
            districtService?.dispose()
        }
    }
}

extension DeviceDataService: AMapLocationManagerDelegate {
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        self.rxLocation.value = location
    }
}
