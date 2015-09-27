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

class DeviceDataService: NSObject {
    static let sharedInstance = DeviceDataService()

    let motionManager = CMMotionManager()
    let altitudeManager = CMAltimeter()

    var searchApi: AMapSearchAPI!
    var districtService: Disposable?

    var rx_acceleration: Variable<CMAcceleration?> = Variable(nil)
    var rx_altitude: Variable<CMAltitudeData?> = Variable(nil)
    var rx_location: Variable<CLLocation?> = Variable(nil)
    var rx_district = Variable("正在获取位置信息")

    override init() {
        super.init()

        searchApi = AMapSearchAPI(searchKey: AMAP_KEY, delegate: self)

        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) in
                if let validData = data {
                    self.rx_acceleration.value = validData.userAcceleration
                }
            })
        }

        if CMAltimeter.isRelativeAltitudeAvailable() {
            altitudeManager.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) in
                if let validData = data {
                    self.rx_altitude.value = validData
                }
            })
        }

        timer(0, 60, MainScheduler.sharedInstance).subscribeNext { _ in
            self.districtService = self.rx_location.subscribeNext { location in
                guard let location = location else {
                    return
                }
                let regeoRequest = AMapReGeocodeSearchRequest()
                regeoRequest.searchType = .ReGeocode
                regeoRequest.location = AMapGeoPoint.locationWithLatitude(CGFloat(location.coordinate.latitude), longitude: CGFloat(location.coordinate.longitude))
                regeoRequest.requireExtension = true

                self.searchApi.AMapReGoecodeSearch(regeoRequest)
            }
        }
    }
}

extension DeviceDataService: AMapSearchDelegate {
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        let city = response.regeocode.addressComponent.city == "" ? response.regeocode.addressComponent.district : response.regeocode.addressComponent.city
        self.rx_district.value = "\(response.regeocode.addressComponent.province)\(city)"
        districtService?.dispose()
    }
}