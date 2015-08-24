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
    
    @IBOutlet weak var scoreTable: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var progressView: UIImageView!
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    let motionManager = CMMotionManager()
    let altitudeManager = CMAltimeter()
    
    let scoreTitles = ["天门山通天大道", "台州鸟山", "云南三家村"]
    let scores = ["7:24.36s", "9:05.18s", "5:42.55s"]

    override func viewDidLoad() {
        super.viewDidLoad()
        initMotion()
        initLocation()
        initAltitude()
        
        initTable()
    }
    
    func initMotion() {
        guard motionManager.deviceMotionAvailable else {
            aLabel.text = "0"
            progressWidth.constant = 0
            progressView.layoutIfNeeded()
            return
        }
        motionManager.deviceMotionUpdateInterval = 0.01
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
            guard let validData = data else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let curX = validData.userAcceleration.x
                let curY = validData.userAcceleration.y
                //let curZ = validData.userAcceleration.z
                let parent = self.parentViewController as? TraceViewController
                parent?.a = curY*10
                self.aLabel.text = String(format: "%.0f", Double.abs(curY*10))
                let constant = Double.abs(self.calculateTyreWear(curX, v: ApiHeader.sharedInstance.location?.speed ?? 0)) * 310
                UIView.animateWithDuration(0.1, animations: {
                    self.progressWidth.constant = CGFloat(constant > 310 ? 310 : constant)
                    self.progressView.layoutIfNeeded()
                })
            })
        })
    }
    
    func calculateTyreWear(ax: Double, v: Double) -> Double {
        if Int(v) == 0 { return 0 }
        return ax * v * 36 / 1000
    }
    
    func initLocation() {
        ApiHeader.sharedInstance.delegate = self
    }
    
    func initAltitude() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            pressureLabel.text = "NaN"
            return
        }
        
        altitudeManager.startRelativeAltitudeUpdatesToQueue(NSOperationQueue(), withHandler: { (data, error) in
            guard let validData = data else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.pressureLabel.text = String(Int(validData.pressure.doubleValue*10))
            })
        })
    }
    
    func initTable() {
        scoreTable.delegate = self
        scoreTable.dataSource = self
    }
}

extension DataViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("score") as UITableViewCell!
        let title = cell.viewWithTag(301) as? UILabel
        let score = cell.viewWithTag(302) as? UILabel
        title?.text = scoreTitles[indexPath.row]
        score?.text = scores[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension DataViewController: LocationUpdateDelegate {
    func didLocationUpdated(location: CLLocation) {
        self.vLabel.text = String(format: "%.0f", location.speed < 0 ? 0 : location.speed * 3.6)
        self.altitude.text = String(format: "%.0f", location.altitude)
        self.lonLabel.text = location.coordinate.longitudeString()
        self.latLabel.text = location.coordinate.latitudeString()
    }
}
