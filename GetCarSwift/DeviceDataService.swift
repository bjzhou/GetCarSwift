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

class DeviceDataService: NSObject, MAMapViewDelegate {
    static let sharedInstance = DeviceDataService()

    let motionManager = CMMotionManager()
    let altitudeManager = CMAltimeter()

    var rx_acceleration: Variable<CMAcceleration?> = Variable(nil)
    var rx_altitude: Variable<CMAltitudeData?> = Variable(nil)
    var rx_location: Variable<CLLocation?> = Variable(nil)

    override init() {
        super.init()

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
    }
}
