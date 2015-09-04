//
//  DataViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
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

    let scoreTitles = ["天门山通天大道", "台州鸟山", "云南三家村"]
    let scores = ["7:24.36s", "9:05.18s", "5:42.55s"]

    override func viewDidLoad() {
        super.viewDidLoad()

        DataKeeper.sharedInstance.addDelegate(self)
        scoreTable.delegate = self
        scoreTable.dataSource = self
    }

    @IBAction func didGo(sender: UIButton) {
        let attributedMessage = NSAttributedString.loadHTMLString("<font size=4>在通过设定的起点和终点时将会自动启动与结束码表，不用手动启动与结束。<br/><br/>进入计时前，请仔细阅读<b>《使用条款以及免责声明》</b>。进入计时，即视为认同我司的<b>《使用条款以及免责声明》</b></font>")
        let alertController = UIAlertController(title: "自动计时器", message: "", preferredStyle: .Alert)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        alertController.addAction(UIAlertAction(title: "进入计时", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}

extension DataViewController: DataKeeperDelegate {

    func didLocationUpdated(location: CLLocation) {
        self.vLabel.text = String(format: "%.0f", location.speed < 0 ? 0 : location.speed * 3.6)
        self.altitude.text = String(format: "%.0f", location.altitude)
        self.lonLabel.text = location.coordinate.longitudeString()
        self.latLabel.text = location.coordinate.latitudeString()
    }

    func didAccelerationUpdated(acceleration: CMAcceleration) {
        let curX = acceleration.x
        let curY = acceleration.y
        //let curZ = acceleration.z
        let parent = self.parentViewController as? TraceViewController
        parent?.a = curY*10
        self.aLabel.text = String(format: "%.0f", Double.abs(curY*10))
        let constant = Double.abs(self.calculateTyreWear(curX, v: DataKeeper.sharedInstance.location?.speed ?? 0)) * 310
        UIView.animateWithDuration(0.1, animations: {
            self.progressWidth.constant = CGFloat(constant > 310 ? 310 : constant)
            self.progressView.layoutIfNeeded()
        })
    }

    func calculateTyreWear(ax: Double, v: Double) -> Double {
        if Int(v) == 0 { return 0 }
        return ax * v * 36 / 1000
    }

    func didAltitudeUpdated(altitude: CMAltitudeData) {
        self.pressureLabel.text = String(Int(altitude.pressure.doubleValue*10))
    }

}
