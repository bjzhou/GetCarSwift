//
//  DataViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit
import CoreMotion

class DataViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var altitude: UILabel!
    
    let motionManager = CMMotionManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard motionManager.accelerometerAvailable else {
            aLabel.text = "此设备不支持加速度传感器"
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            vLabel.text = "此设备不支持GPS"
            return
        }

        motionManager.accelerometerUpdateInterval = 0.01
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
            guard let validData = data else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let curX = validData.acceleration.x
                let curY = validData.acceleration.y
                let curZ = validData.acceleration.z
                self.aLabel.text = String(format: "加速度: x=%.2f, y=%.2f, z=%.2f", curX, curY, curZ)
            })
            
        })
        locationManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.vLabel.text = String(format: "速度: %.2f km/h", location.speed > 0 ? location.speed * 3.6 : 0)
            self.altitude.text = String(format: "海拔: %i m", abs(location.altitude) > 20000 ? 0 : location.altitude)
        })
    }

}
