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
    var startLoc: CLLocation?

    var _100dir = File(path: "100")

    var prevKey = 0.0
    var data: Score = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        _100dir.mkdir()

//        DeviceDataService.sharedInstance.rx_altitude.subscribeNext { altitude in
//            if let altitude = altitude {
//                self.pressureLabel.text = String(Int(altitude.pressure.doubleValue*10))
//            }
//        }.addDisposableTo(disposeBag)

        combineLatest(DeviceDataService.sharedInstance.rx_location, DeviceDataService.sharedInstance.rx_acceleration) { (loc, acce) in
            return (loc, acce)
            }.subscribeNext { (loc, acce) in
                if let loc = loc, acce = acce {
                    self.lonLabel.text = String(format: "%.0fm", loc.horizontalAccuracy)
                    if self.ready && loc.speed != 0.0 {
                        self.ready = false
                        self.startLoc = loc
                        self.startTimer()
                    }
                    if loc.speed == 0.0 && abs(acce.z) <= 0.1 && self.pressed {
                        self.pressed = false
                        self.ready = true
                    }
                }
        }.addDisposableTo(disposeBag)

//        DeviceDataService.sharedInstance.rx_acceleration.subscribeNext { acce in
//            if let acce = acce {
//                if self.ready && abs(acce.y) > 0.1 {
//                    self.ready = false
//                    self.startTimer()
//                }
//                if abs(acce.y) <= 0.1 && self.pressed {
//                    self.pressed = false
//                    self.ready = true
//                }
//            }
//        }.addDisposableTo(disposeBag)
    }

    override func viewDidDisappear(animated: Bool) {
        stopTimer()
        ready = false
        pressed = false
    }

    func startTimer() {
        _10msTimer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let tms = t % 100
            let s = t / 100 % 60
            let m = t / 100 / 60
            self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

            if let loc = DeviceDataService.sharedInstance.rx_location.value, acce = DeviceDataService.sharedInstance.rx_acceleration.value {
                self.vLabel.text = String(format: "%.2f", loc.speed < 0 ? 0 : loc.speed * 3.6)

                if let startLoc = self.startLoc {
                    let meters = startLoc.distanceFromLocation(loc)
                    self.latLabel.text = String(format: "%.1fm", meters)

                    if meters != self.data[self.prevKey]?["meters"] ?? 0 {
                        self.data[Double(t)/100] = ["speed": loc.speed, "acce": acce.y, "meters": meters]
                        self.prevKey = Double(t)/100
                    }

                    if meters >= 100 {
                        self.altitude.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])
                        self.pressureLabel.text = String(format: "%.2f km/h", 100/(Double(t)/100)*3.6)
                        self.stopTimer()
                        let file = try! File(dir: self._100dir, name: "test" + String(self._100dir.list().count))
                        NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)
                    }
                } else {
                    self.latLabel.text = "NaN"
                }

                self.aLabel.text = String(format: "%.0f", Double.abs(acce.y*9.81))
            }

//            print(self.data[Double(t-1)/100])
//            //let prevAx = self.data[Double(t-1)/100]?["ax"] ?? 0.0
//            //let prevAy = self.data[Double(t-1)/100]?["ay"] ?? 0.0
//            //let prevAz = self.data[Double(t-1)/100]?["az"] ?? 0.0
//            let prevV = self.data[Double(t-1)/100]?["v"] ?? 0.0
//            let prevS = self.data[Double(t-1)/100]?["s"] ?? 0.0
//            if let acce = DeviceDataService.sharedInstance.rx_acceleration.value {
//                //let ax = acce.x
//                let ay = acce.y * 9.81
//                //let az = acce.z
//                let s = ay * 0.01 * 0.01 + prevS
//                let v = ay * 0.01 + prevV
//
//                self.vLabel.text = String(format: "%.2f", v * 3.6)
//                self.latLabel.text = String(format: "%.1fm", s)
//                self.aLabel.text = String(format: "%.1f", Double.abs(ay*9.81))
//
//                self.data[Double(t)/100] = ["ay": ay, "v": v, "s": s]
//
//                if s >= 100 {
//                    self.altitude.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])
//                    self.pressureLabel.text = String(format: "%.2f km/h", 100/(Double(t)/100)*3.6)
//                    self.stopTimer()
//                    let file = try! File(dir: self._100dir, name: "test" + String(self._100dir.list().count))
//                    NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)
//                }
//            } else {
//                self.data[Double(t)/100] = ["ay": 0, "v": 0, "s": prevS]
//            }
        }
    }

    func stopTimer() {
        _10msTimer?.dispose()
        self.timeLabel.text = "00:00.00"
    }

    @IBAction func didGo(sender: UIButton) {
        let alertController = UIAlertController(title: "自动计时器", message: "", preferredStyle: .Alert)
        if let loc = DeviceDataService.sharedInstance.rx_location.value where loc.horizontalAccuracy < 65 {
            {
                 return NSAttributedString.loadHTMLString("<font size=4>在通过设定的起点和终点时将会自动启动与结束码表，不用手动启动与结束。<br/><br/>进入计时前，请仔细阅读<b>《使用条款以及免责声明》</b>。进入计时，即视为认同我司的<b>《使用条款以及免责声明》</b></font>")
                } ~> { s in
                    alertController.setValue(s, forKey: "attributedMessage")
            }
            alertController.addAction(UIAlertAction(title: "进入计时", style: .Default, handler: { _ in
                self.timeLabel.text = "00:00.00"
                self.pressed = true
            }))
        } else {
            let msg = "正在定位，请稍后再试"
            alertController.message = msg
            alertController.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))
        }

        presentViewController(alertController, animated: true, completion: nil)
    }

}
