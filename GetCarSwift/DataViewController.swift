//
//  DataViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit
import CoreMotion

class DataViewController: UIViewController {
    
    @IBOutlet weak var maxData: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    let motionManager = CMMotionManager()
    
    var maxX: Double = -Double.infinity
    var maxY: Double = -Double.infinity
    var maxZ: Double = -Double.infinity

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard motionManager.accelerometerAvailable else {
            dataLabel.text = "此设备不支持加速度传感器"
            return
        }

        motionManager.accelerometerUpdateInterval = 0.01

    }
    
    override func viewDidAppear(animated: Bool) {
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
            guard let validData = data else {
                return
            }
            
            
            dispatch_async(dispatch_get_main_queue(), {
                let curX = validData.acceleration.x
                let curY = validData.acceleration.y
                let curZ = validData.acceleration.z
                self.maxX = max(curX, self.maxX)
                self.maxY = max(curY, self.maxY)
                self.maxZ = max(curZ, self.maxZ)
                self.dataLabel.text = String(format: "x : %.2f, y : %.2f, z : %.2f", curX, curY, curZ)
                self.maxData.text = String(format: "max x : %.2f, max y : %.2f, max z : %.2f", self.maxX, self.maxY, self.maxZ)
            })
            
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        motionManager.stopAccelerometerUpdates()
    }

}
