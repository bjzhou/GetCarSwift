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
    @IBOutlet weak var data0: SwiftPages!
    @IBOutlet weak var data1: SwiftPages!
    @IBOutlet weak var data2: SwiftPages!
    @IBOutlet weak var data3: SwiftPages!

    var datas = [SwiftPages]()
    var dataVCs = [DataSubViewController]()
    let dataTitles = ["0~100m", "0~400m", "0~60km/h", "0~100km/h", "30~50km/h", "50~70km/h", "60~0km/h", "100~0km/h"]

    var _msTimer: Disposable?

    var ready = false
    var startLoc: CLLocation?
    var acces = Acces()

    var _100dir = File(path: "100")

    var prevKey = 0.0
    var data: Score = [:]
    var keyTime = [String:Double]()
    var lastA = 0.0
    var scores = [Double]()

    struct Acces {
        var acces = [CMAcceleration]()

        mutating func append(value: CMAcceleration) {
            if acces.count >= 10 {
                acces.removeFirst()
            }
            acces.append(value)
        }

        func averageA() -> Double {
            let count = Double(acces.count)
            let acce = acces.reduce((0.0,0.0,0.0), combine: { ($0.0 + $1.x / count, $0.1 + $1.y / count, $0.2 + $1.z / count) })
            //print(acce)
            return sqrt(acce.0 * acce.0 + acce.1 * acce.1 * acce.2 * acce.2) * 9.81
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        _100dir.mkdir()

        initPages()

        DeviceDataService.sharedInstance.rx_acceleration.subscribeNext { acce in
            if let acce = acce {
                self.acces.append(acce)
            }
            if let loc = DeviceDataService.sharedInstance.rx_location.value {
                let a = self.acces.averageA()
                self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", loc.speed < 0 ? 0 : loc.speed * 3.6, a)
                if self.ready && (loc.speed > 0 || a >= 0.5) {
                    self.startLoc = loc
                    self.startTimer()
                }
                if loc.speed <= 0.1 && a < 0.5 {
                    self.stopTimer()
                }
            }
        }.addDisposableTo(disposeBag)
    }

    func initPages() {

        datas = [data0, data1, data2, data3]
        let scale: CGFloat = self.view.bounds.height / 667
        for var i=0; i<4; i++ {
            datas[i].setTopBarImage(nil)
            datas[i].setTopBarHeight(21*scale)
            datas[i].setAnimatedBarHeight(3)
            datas[i].setButtonsTextColor(UIColor(white: 1, alpha: 0.7))
            datas[i].setContainerViewBackground(UIColor.clearColor())
            datas[i].setButtonsTextFontAndSize(UIFont.systemFontOfSize(14*scale))

            dataVCs.append(DataSubViewController())
            dataVCs.append(DataSubViewController())

            datas[i].initializeWithVCsArrayAndButtonTitlesArray([dataVCs[i*2], dataVCs[i*2+1]], buttonTitlesArray: [dataTitles[i*2], dataTitles[i*2+1]], sender: self)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        stopTimer()
    }

    func time2String(t: Double) -> String {
        let ms = Int(t*100) % 100
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    func fixTime(t: Double, prevT: Double, v: Double, expectV: Double) -> Double {
        let dt = t - prevT
        if let prevV = self.data[prevT]?["v"] where dt != 0 && prevV != 0 {
            let a = (v - prevV) / dt
            if a == 0 { return t }
            let expectDt = (expectV - prevV) / a
            print(t, prevT, v, prevV, expectV, expectDt)
            return prevT + expectDt
        } else {
            return t
        }
    }

    func fixTime(t: Double, prevT: Double, v: Double, expectS: Double) -> Double {
        let dt = t - prevT
        if let prevV = self.data[prevT]?["v"], prevS = self.data[prevT]?["s"] where dt != 0 {
            let a = (v - prevV) / dt
            if a == 0 { return t }
            let expectDt = sqrt(abs((expectS - prevS) / a))
            return prevT + expectDt
        } else {
            return t
        }
    }

    func startTimer() {
        UIApplication.sharedApplication().idleTimerDisabled = true
        scores.removeAll()
        for _ in dataVCs {
            //vc.time = "--:--.--"
            scores.append(-1)
        }
        self.data.removeAll()
        self.lastA = 0.0
        self.prevKey = 0
        self.keyTime.removeAll()
        self.ready = false
        _msTimer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let curTs = self.time2String(Double(t)/100)
            self.timeLabel.text = curTs

            if let loc = DeviceDataService.sharedInstance.rx_location.value {
                if let startLoc = self.startLoc {
                    let v = loc.speed <= 0 ? 0 : (loc.speed * 3.6)
                    let s = startLoc.distanceFromLocation(loc)
                    let a = self.acces.averageA()

                    //let prevA = self.data[self.prevKey]?["a"] ?? 0
                    let prevS = self.data[self.prevKey]?["s"] ?? 0
                    let prevV = self.data[self.prevKey]?["v"] ?? 0


                    if s >= 100 && prevS < 100 {
                        if self.scores[0] == -1 {
                            self.scores[0] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectS: 100)
                            self.dataVCs[0].time = self.time2String(self.scores[0])
                        }
                    }

                    if s >= 400 && prevS < 400 {
                        if self.scores[1] == -1 {
                            self.scores[1] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectS: 400)
                            self.dataVCs[1].time = self.time2String(self.scores[1])
                        }
                    }

                    if v >= 30 && prevV < 30 {
                        self.keyTime["30"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 30)
                    }

                    if v >= 50 && prevV < 50 {
                        self.keyTime["50"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 50)

                        if self.scores[4] == -1 {
                            let dt = self.keyTime["50"]! - self.keyTime["30"]!
                            self.scores[4] = dt
                            self.dataVCs[4].time = self.time2String(self.scores[4])
                        }
                    }

                    if v >= 60 && prevV < 60 {
                        self.keyTime["60"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 60)
                        if self.scores[2] == -1 {
                            self.scores[2] = self.keyTime["60"]!
                            self.dataVCs[2].time = self.time2String(self.scores[2])
                            async {
                                var data = self.data
                                data[self.scores[2]] = ["v": 60.0, "a": a, "s": s]
                                let file = try! File(dir: self._100dir, name: "v60_\(self._100dir.list().count).dat")
                                NSKeyedArchiver.archiveRootObject(data, toFile: file.path)
                            }
                        }
                    }

                    if v <= 60 && prevV > 60 {
                        self.keyTime["60"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 60)
                    }

                    if v >= 70 && prevV < 70 {
                        self.keyTime["70"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 70)

                        if self.scores[5] == -1 {
                            let dt = self.keyTime["70"]! - self.keyTime["50"]!
                            self.scores[5] = dt
                            self.dataVCs[5].time = self.time2String(self.scores[5])
                        }
                    }

                    if v >= 100 && prevV < 100 {
                        self.keyTime["100"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 100)
                        if self.scores[3] == -1 {
                            self.scores[3] = self.keyTime["100"]!
                            self.dataVCs[3].time = self.time2String(self.scores[3])
                            async {
                                var data = self.data
                                data[self.scores[3]] = ["v": 100.0, "a": a, "s": s]
                                let file = try! File(dir: self._100dir, name: "v100_\(self._100dir.list().count).dat")
                                NSKeyedArchiver.archiveRootObject(data, toFile: file.path)
                            }
                        }
                    }

                    if v <= 100 && prevV > 100 {
                        self.keyTime["100"] = self.fixTime(Double(t)/100, prevT: self.prevKey, v: v, expectV: 100)
                    }

                    if v <= 2 && prevV != 0 {
                        let dt = Double(t) / 100 - self.prevKey
                        if self.lastA == 0.0 && dt != 0 {
                            self.lastA = (v - prevV) / dt
                        }
                        let newV = prevV + self.lastA * dt
                        self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", newV <= 0 ? 0 : newV, a)

                        if newV <= 0.0 {
                            if let v60 = self.keyTime["60"] where v60 != 0 {
                                let dt = Double(t)/100 - v60
                                if self.scores[6] == -1 {
                                    self.scores[6] = dt
                                    self.dataVCs[6].time = self.time2String(dt)
                                }
                            }
                            if let v100 = self.keyTime["100"] where v100 != 0 {
                                let dt = Double(t)/100 - v100
                                if self.scores[7] == -1 {
                                    self.scores[7] = dt
                                    self.dataVCs[7].time = self.time2String(dt)
                                }
                            }
                            self.stopTimer()
                        }
                    }

                    if s != self.data[self.prevKey]?["s"] ?? 0 {
                        self.data[Double(t)/100] = ["v": v, "a": a, "s": s]
                        self.prevKey = Double(t)/100
                    }
                }
            }
        }
    }

    func stopTimer() {
        UIApplication.sharedApplication().idleTimerDisabled = false
        _msTimer?.dispose()
        self.timeLabel.text = "00:00.00"
        self.ready = true
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
