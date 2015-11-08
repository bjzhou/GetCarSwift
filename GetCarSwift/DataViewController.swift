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

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var data0: SwiftPages!
    @IBOutlet weak var data1: SwiftPages!
    @IBOutlet weak var data2: SwiftPages!
    @IBOutlet weak var data3: SwiftPages!

    var datas = [SwiftPages]()
    var dataVCs = [DataSubViewController]()
    let dataTitles = ["0~100m", "0~400m", "0~60km/h", "0~100km/h", "30~50km/h", "50~70km/h", "60~0km/h", "100~0km/h"]

    var _msTimer: Disposable?

    var pressed = false
    var ready = false
    var startLoc: CLLocation?

    var _100dir = File(path: "100")

    var prevKey = 0.0
    var data: Score = [:]
    var keyTime = [String:Int64]()

    override func viewDidLoad() {
        super.viewDidLoad()

        _100dir.mkdir()

        initPages()

//        DeviceDataService.sharedInstance.rx_altitude.subscribeNext { altitude in
//            if let altitude = altitude {
//                self.pressureLabel.text = String(Int(altitude.pressure.doubleValue*10))
//            }
//        }.addDisposableTo(disposeBag)

        combineLatest(DeviceDataService.sharedInstance.rx_location, DeviceDataService.sharedInstance.rx_acceleration) { (loc, acce) in
            return (loc, acce)
            }.subscribeNext { (loc, acce) in
                if let loc = loc, acce = acce {
                    //self.lonLabel.text = String(format: "%.0fm", loc.horizontalAccuracy)
                    if self.ready && (abs(acce.y) > 0.1 || loc.speed > 0.1) {
                        self.ready = false
                        self.startLoc = loc
                        self.keyTime.removeAll()
                        self.startTimer()
                    }
                    if loc.speed <= 0.0 && abs(acce.z) <= 0.1 && self.pressed {
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

    func initPages() {

        datas = [data0, data1, data2, data3]

        for var i=0; i<4; i++ {
            datas[i].setTopBarImage(nil)
            datas[i].setTopBarHeight(20)
            datas[i].setAnimatedBarHeight(3)
            datas[i].setButtonsTextColor(UIColor(white: 1, alpha: 0.7))
            datas[i].setContainerViewBackground(UIColor.clearColor())
            datas[i].setButtonsTextFontAndSize(UIFont.systemFontOfSize(14))

            dataVCs.append(DataSubViewController())
            dataVCs.append(DataSubViewController())

            datas[i].initializeWithVCsArrayAndButtonTitlesArray([dataVCs[i*2], dataVCs[i*2+1]], buttonTitlesArray: [dataTitles[i*2], dataTitles[i*2+1]], sender: self)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        stopTimer()
        ready = false
        pressed = false
    }

    func startTimer() {
        _msTimer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let ms = t % 100
            let s = t / 100 % 60
            let m = t / 100 / 60
            let timeString = String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
            self.timeLabel.text = timeString

            if let loc = DeviceDataService.sharedInstance.rx_location.value, acce = DeviceDataService.sharedInstance.rx_acceleration.value {
                self.vLabel.text = String(format: "%.0f km/h", loc.speed < 0 ? 0 : loc.speed * 3.6)

                if let startLoc = self.startLoc {
                    let meters = startLoc.distanceFromLocation(loc)

                    let prevMeters = self.data[self.prevKey]?["meters"] ?? 0
                    let prevSpeed = self.data[self.prevKey]?["speed"] ?? 0

                    if meters != self.data[self.prevKey]?["meters"] ?? 0 {
                        self.data[Double(t)/100] = ["speed": loc.speed, "acce": acce.y, "meters": meters]
                        self.prevKey = Double(t)/100
                    }

                    if meters >= 100 && prevMeters < 100 {
                        let file = try! File(dir: self._100dir, name: "100_\(self._100dir.list().count).dat")
                        NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)

                        self.dataVCs[0].time = timeString
                    }

                    if meters >= 400 && prevMeters < 400 {
                        let file = try! File(dir: self._100dir, name: "400_\(self._100dir.list().count).dat")
                        NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)

                        self.dataVCs[1].time = timeString
                    }

                    if loc.speed * 3.6 >= 30 && prevSpeed * 3.6 < 30 {
                        self.keyTime["30"] = t
                    }

                    if loc.speed * 3.6 >= 50 && prevSpeed * 3.6 < 50 {
                        self.keyTime["50"] = t

                        let dt = t - self.keyTime["30"]!
                        //let file = try! File(dir: self._100dir, name: "s30_50_\(self._100dir.list().count).dat")
                        //NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)

                        self.dataVCs[4].time = String(format: "%02d:%02d.%02d", arguments: [dt/100/60, dt/100%60, dt%100])
                    }

                    if loc.speed * 3.6 >= 60 && prevSpeed * 3.6 < 60 {
                        self.keyTime["60"] = t
                        //let file = try! File(dir: self._100dir, name: "s60_\(self._100dir.list().count).dat")
                        //NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)

                        self.dataVCs[2].time = timeString
                    }

                    if loc.speed * 3.6 >= 70 && prevSpeed * 3.6 < 70 {
                        self.keyTime["70"] = t

                        let dt = t - self.keyTime["50"]!
                        //let file = try! File(dir: self._100dir, name: "s50_70_\(self._100dir.list().count).dat")
                        //NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)

                        self.dataVCs[5].time = String(format: "%02d:%02d.%02d", arguments: [dt/100/60, dt/100%60, dt%100])
                    }

                    if loc.speed * 3.6 >= 100 && prevSpeed * 3.6 < 100 {
                        self.keyTime["100"] = t
                        //let file = try! File(dir: self._100dir, name: "s100_\(self._100dir.list().count).dat")
                        //NSKeyedArchiver.archiveRootObject(self.data, toFile: file.path)

                        self.dataVCs[3].time = timeString
                    }

                    if loc.speed * 3.6 <= 0.5 && prevSpeed * 3.6 > 0.5 {
                        if let s60 = self.keyTime["60"] {
                            let dt0 = t - s60
                            //let file0 = try! File(dir: self._100dir, name: "s60_0_\(self._100dir.list().count).dat")
                            //NSKeyedArchiver.archiveRootObject(self.data, toFile: file0.path)

                            self.dataVCs[6].time = String(format: "%02d:%02d.%02d", arguments: [dt0/100/60, dt0/100%60, dt0%100])
                        }

                        if let s100 = self.keyTime["100"] {
                            let dt1 = t - s100
                            //let file1 = try! File(dir: self._100dir, name: "s100_0_\(self._100dir.list().count).dat")
                            //NSKeyedArchiver.archiveRootObject(self.data, toFile: file1.path)

                            self.dataVCs[7].time = String(format: "%02d:%02d.%02d", arguments: [dt1/100/60, dt1/100%60, dt1%100])
                        }
                    }

                    if loc.speed < 0.1 && prevSpeed > 0.1 {
                        self.stopTimer()
                    }
                } else {
                    //self.latLabel.text = "NaN"
                }

                //self.aLabel.text = String(format: "%.0f", Double.abs(acce.y*9.81))
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
        goButton.selected = false
        _msTimer?.dispose()
        self.timeLabel.text = "00:00.00"
    }

    @IBAction func didGo(sender: UIButton) {
        if sender.selected {
            stopTimer()
            return
        }

        self.goButton.selected = true
        let alertController = UIAlertController(title: "自动计时器", message: "", preferredStyle: .Alert)
        if let loc = DeviceDataService.sharedInstance.rx_location.value where loc.horizontalAccuracy <= 65 {
            alertController.setValue(alertStr, forKey: "attributedMessage")
            alertController.addAction(UIAlertAction(title: "进入计时", style: .Default, handler: { _ in
                self.pressed = true
            }))
        } else {
            let msg = "正在定位，请稍后再试"
            alertController.message = msg
            alertController.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))

            self.goButton.selected = false
        }

        presentViewController(alertController, animated: true, completion: nil)
    }
}

class DataSubViewController: UIViewController {

    let label = UILabel()
    var time = "--:--.--" {
        didSet {
            label.text = time
        }
    }

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.clearColor()
    }

    override func viewDidLayoutSubviews() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(30)
        label.text = time
        self.view.addSubview(label)

        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
    }
}
