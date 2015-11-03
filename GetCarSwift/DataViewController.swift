//
//  DataViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import CoreMotion
import RxSwift

class DataViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!

    var _10msTimer: Disposable?

    var pressed = false
    var ready = false
    var startLoc = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        DeviceDataService.sharedInstance.rx_location.subscribeNext { location in
            if let location = location {
                self.vLabel.text = String(format: "%.2f", location.speed < 0 ? 0 : location.speed * 3.6)
                self.lonLabel.text = String(format: "%.0fm", location.horizontalAccuracy)
            }
        }.addDisposableTo(disposeBag)

        DeviceDataService.sharedInstance.rx_acceleration.subscribeNext { acceleration in
            if let acceleration = acceleration {
                //let curX = acceleration.x
                let curY = acceleration.y
                //let curZ = acceleration.z
                self.aLabel.text = String(format: "%.0f", Double.abs(curY*10))
            }
        }.addDisposableTo(disposeBag)

//        DeviceDataService.sharedInstance.rx_altitude.subscribeNext { altitude in
//            if let altitude = altitude {
//                self.pressureLabel.text = String(Int(altitude.pressure.doubleValue*10))
//            }
//        }.addDisposableTo(disposeBag)

        combineLatest(DeviceDataService.sharedInstance.rx_location, DeviceDataService.sharedInstance.rx_acceleration) { (loc, acce) in
            return (loc, acce)
            }.subscribeNext { (loc, acce) in
                if let loc = loc, acce = acce {
                    if self.ready && loc.speed != 0.0 {
                        self.ready = false
                        self.startTimer()
                    }
                    if loc.speed == 0.0 && abs(acce.z) <= 0.1 && self.pressed {
                        self.pressed = false
                        self.ready = true
                    }
                }
        }.addDisposableTo(disposeBag)
    }

    override func viewDidDisappear(animated: Bool) {
        _10msTimer?.dispose()
        ready = false
        pressed = false
    }

    func startTimer() {
        _10msTimer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let tms = t % 100
            let s = t / 100 % 60
            let m = t / 100 / 60
            self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

            if let loc = DeviceDataService.sharedInstance.rx_location.value {
                let p0 = MAMapPointForCoordinate(self.startLoc)
                let p1 = MAMapPointForCoordinate(loc.coordinate)
                let meters = MAMetersBetweenMapPoints(p0, p1)
                self.altitude.text = String(format: "%.1fm", meters)
                if meters >= 100 {
                    self.altitude.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])
                    self.pressureLabel.text = String(format: "%.2f km/h", 100/(Double(t)/100)*3.6)
                    self.timeLabel.text = "00:00.00"
                    self._10msTimer?.dispose()
                }
            }
        }
    }

    @IBAction func didGo(sender: UIButton) {
        let alertController = UIAlertController(title: "自动计时器", message: "", preferredStyle: .Alert)
        if let loc = DeviceDataService.sharedInstance.rx_location.value where loc.horizontalAccuracy <= 65 {
            {
                 return NSAttributedString.loadHTMLString("<font size=4>在通过设定的起点和终点时将会自动启动与结束码表，不用手动启动与结束。<br/><br/>进入计时前，请仔细阅读<b>《使用条款以及免责声明》</b>。进入计时，即视为认同我司的<b>《使用条款以及免责声明》</b></font>")
                } ~> { s in
                    alertController.setValue(s, forKey: "attributedMessage")
            }
            alertController.addAction(UIAlertAction(title: "进入计时", style: .Default, handler: { _ in
                self.timeLabel.text = "00:00.00"
                if let loc = DeviceDataService.sharedInstance.rx_location.value {
                    self.startLoc = loc.coordinate
                    self.pressed = true
                }
            }))
        } else {
            let msg = "正在定位，请稍后再试"
            alertController.message = msg
            alertController.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))
        }

        presentViewController(alertController, animated: true, completion: nil)
    }

}
