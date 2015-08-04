//
//  DataViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit
import CoreMotion

protocol AccelerationUpdateDelegate {
    func onLeft()
    func onRight()
}

class DataViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var altitude: UILabel!
    
    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()
    
    var delegate: AccelerationUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard motionManager.deviceMotionAvailable else {
            aLabel.text = "此设备不支持加速度传感器或陀螺仪"
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            vLabel.text = "此设备不支持GPS"
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.01
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
            guard let validData = data else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let curX = validData.userAcceleration.x
                let curY = validData.userAcceleration.y
                let curZ = validData.userAcceleration.z
                self.aLabel.text = String(format: "加速度: x=%.1f, y=%.1f, z=%.1f", curX, curY, curZ)
                if curX < -2.5 {
                    self.delegate?.onLeft()
                } else if curX > 2.5 {
                    self.delegate?.onRight()
                }
            })
        })
//        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
//            guard let validData = data else {
//                return
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                let curX = validData.acceleration.x
//                let curY = validData.acceleration.y
//                let curZ = validData.acceleration.z
//                self.aLabel.text = String(format: "加速度: x=%.2f, y=%.2f, z=%.2f", curX, curY, curZ)
//            })
//            
//        })
        locationManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.vLabel.text = String(format: "速度: %.2f km/h", location.speed > 0 ? location.speed * 3.6 : 0)
            self.altitude.text = String(format: "海拔: %.2f m", location.altitude)
        })
    }

}
