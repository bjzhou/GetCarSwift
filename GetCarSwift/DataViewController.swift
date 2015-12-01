//
//  DataViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RealmSwift

class DataViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var data0: UIView!
    @IBOutlet weak var data1: UIView!
    @IBOutlet weak var data2: UIView!
    @IBOutlet weak var data3: UIView!
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var bestButton: UIButton!

    @IBOutlet weak var signalView1: UIImageView!
    @IBOutlet weak var signalView2: UIImageView!
    @IBOutlet weak var signalView3: UIImageView!
    @IBOutlet weak var signalView4: UIImageView!
    @IBOutlet weak var signalView5: UIImageView!

    let realm = try! Realm()

    var datas = [UIView]()
    var dataVCs = [DataSubViewController]()
    let dataTitles = ["0~60km/h", "0~100km/h", "60~0km/h", "0~400m"]

    var timerDisposable: Disposable?

    var ready = false

    var startLoc: CLLocation?

    var data = List<RmScoreData>()
    var keyTime = [String:Double]()

    var showBest = false {
        didSet {
            updateScore()
        }
    }
    var latestScores = [-1.0, -1.0, -1.0, -1.0]
    var bestScores = [-1.0, -1.0, -1.0, -1.0]

    override func viewDidLoad() {
        super.viewDidLoad()

        initPages()

        let signalViews = [signalView1, signalView2, signalView3, signalView4, signalView5]
        let noSignalImages = [R.image.no_signal_1, R.image.no_signal_2, R.image.no_signal_3, R.image.no_signal_4, R.image.no_signal_5]
        let signalImages = [R.image.signal_1, R.image.signal_2, R.image.signal_3, R.image.signal_4, R.image.signal_5]
        DeviceDataService.sharedInstance.rxLocation.subscribeNext { loc in
            if let loc = loc {
                for i in 0...4 {
                    signalViews[i].image = signalImages[i]
                }
                if loc.horizontalAccuracy > 5 {
                    signalViews[4].image = noSignalImages[4]
                }
                if loc.horizontalAccuracy > 10 {
                    signalViews[3].image = noSignalImages[3]
                }
                if loc.horizontalAccuracy >= 65 {
                    signalViews[2].image = noSignalImages[2]
                }
                if loc.horizontalAccuracy > 65 {
                    signalViews[1].image = noSignalImages[1]
                }
            } else {
                for i in 0...4 {
                    signalViews[i].image = noSignalImages[i]
                }
            }
        }.addDisposableTo(disposeBag)

        DeviceDataService.sharedInstance.rxAcceleration.subscribeNext { acces in
            if let loc = DeviceDataService.sharedInstance.rxLocation.value {
                let a = acces.averageA()
                self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", loc.speed < 0 ? 0 : loc.speed * 3.6, a)
                if self.ready && (loc.speed > 0 || a >= 0.3) {
                    self.startLoc = loc
                    self.startTimer()
                }
                if loc.speed <= 0.1 && a < 0.3 {
                    self.ready = true
                }
            }
        }.addDisposableTo(disposeBag)
    }

    func initPages() {

        datas = [data0, data1, data2, data3]
        for var i=0; i<4; i++ {

            datas[i].layoutIfNeeded()

            let scale: CGFloat = (self.view.frame.height - 410) / 257
            print(scale)

            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: datas[i].frame.width, height: 21*scale))
            titleLabel.textAlignment = .Center
            titleLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            titleLabel.font = UIFont.systemFontOfSize(14*scale)
            titleLabel.text = dataTitles[i]
            let subVc = DataSubViewController()
            subVc.view.frame = CGRect(x: 0, y: 0, width: datas[i].frame.width, height: datas[i].frame.height)
            self.addChildViewController(subVc)
            subVc.didMoveToParentViewController(self)
            dataVCs.append(subVc)
            datas[i].addSubview(titleLabel)
            datas[i].addSubview(subVc.view)
        }
    }

    override func viewDidAppear(animated: Bool) {
        self.updateScore()
    }

    override func viewDidDisappear(animated: Bool) {
        stopTimer()
    }

    @IBAction func didLatestSelected(sender: UIButton) {
        sender.selected = true
        bestButton.selected = false
        showBest = false
    }

    @IBAction func didBestSelected(sender: UIButton) {
        sender.selected = true
        latestButton.selected = false
        showBest = true
    }

    func time2String(t: Double) -> String {
        if t < 0 {
            return "--:--.--"
        }
        let ms = Int(round(t * 100 % 100))
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    func fixScore(t: Double, dataList: List<RmScoreData>, v: Double, expectV: Double) -> Double {
        var expectT = 0.0
        if dataList.count > 1 {
            expectT = dataList.last!.t + fixStart(dataList)
            let dt = t - dataList.last!.t
            if dt != 0 {
                let a = (v - dataList.last!.v) / dt
                if a != 0 {
                    var expectDt = (expectV - dataList.last!.v) / a
                    if expectDt > 1 {
                        expectDt = 1
                    }
                    if expectDt < 0 {
                        expectDt = 0
                    }
                    expectT += expectDt
                }
            }
        }
        return expectT
    }

    func fixScore(t: Double, dataList: List<RmScoreData>, v: Double, expectS: Double) -> Double {
        var expectT = 0.0
        if dataList.count > 1 {
            expectT = dataList.last!.t + fixStart(dataList)
            let dt = t - dataList.last!.t
            if dt != 0 {
                let a = (v - dataList.last!.v) / dt
                if a != 0 {
                    var expectDt = sqrt(abs((expectS - dataList.last!.s) / a))
                    if expectDt > 1 {
                        expectDt = 1
                    }
                    if expectDt < 0 {
                        expectDt = 0
                    }
                    expectT += expectDt
                }
            }
        }
        return expectT
    }

    func fixStart(dataList: List<RmScoreData>) -> Double {
        var i = 0
        for j in 0..<dataList.count {
            if dataList[j].v != 0 {
                i = j
                break
            }
        }
        var expectDt = 0.0
        let dtStart = dataList[i+1].t - dataList[i].t
        if dtStart != 0 {
            let a = (dataList[i+1].v - dataList[i].v) / dtStart
            if a > 0 {
                expectDt = dataList[i].v / a - dataList[i].t
            }
        }
        if expectDt > 1 {
            expectDt = 1
        }
        if expectDt < -1 {
            expectDt = -1
        }
        return expectDt
    }

    func updateScore() {
        let v60s = self.realm.objects(RmScore).filter("type = 'v60'")
        let v100s = self.realm.objects(RmScore).filter("type = 'v100'")
        let s400s = self.realm.objects(RmScore).filter("type = 's400'")
        let b60s = self.realm.objects(RmScore).filter("type = 'b60'")
        self.latestScores[0] =? v60s.sorted("createdAt").last?.score
        self.bestScores[0] =? v60s.sorted("score").first?.score
        self.latestScores[1] =? v100s.sorted("createdAt").last?.score
        self.bestScores[1] =? v100s.sorted("score").first?.score
        self.latestScores[2] =? b60s.sorted("createdAt").last?.score
        self.bestScores[2] =? b60s.sorted("score").first?.score
        self.latestScores[3] =? s400s.sorted("createdAt").last?.score
        self.bestScores[3] =? s400s.sorted("score").first?.score

        for i in 0...3 {
            dataVCs[i].time = self.time2String(showBest ? bestScores[i] : latestScores[i])
        }
    }

    func startTimer() {
        UIApplication.sharedApplication().idleTimerDisabled = true
        self.data.removeAll()
        self.keyTime.removeAll()
        self.ready = false
        self.latestScores = [-1.0, -1.0, -1.0, -1.0]
        timerDisposable?.dispose()
        timerDisposable = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let curTs = self.time2String(Double(t)/100)
            self.timeLabel.text = curTs

            if let loc = DeviceDataService.sharedInstance.rxLocation.value {
                if let startLoc = self.startLoc {
                    var v = loc.speed <= 0 ? 0 : (loc.speed * 3.6)
                    let s = startLoc.distanceFromLocation(loc)
                    let a = DeviceDataService.sharedInstance.rxAcceleration.value.averageA()

                    if let prevData = self.data.last {
                        if self.data.endIndex > 1 {
                            let prevA = (self.data[self.data.endIndex-1].v - self.data[self.data.endIndex-2].v) / 3.6 / (self.data[self.data.endIndex-1].t - self.data[self.data.endIndex-2].t)
                            let calcV = prevData.v + prevA * (Double(t)/100 - prevData.t) * 3.6
                            print("理论速度", calcV, "GPS速度", v)
                            if v == 0 && calcV > 10 {
                                v = calcV
                            }
                        }
                        if s >= 400 && prevData.s < 400 && prevData.s > 200 {
                            if self.latestScores[3] == -1 {
                                self.latestScores[3] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectS: 400)
                                self.bestScores[3] = (self.latestScores[3] < self.bestScores[3]) && (self.bestScores[3] != -1) ? self.latestScores[3] : self.bestScores[3]
                                self.dataVCs[3].time = self.time2String(self.showBest ? self.bestScores[3] : self.latestScores[3])
                                let data = List<RmScoreData>()
                                data.appendContentsOf(self.data)
                                data.append(RmScoreData(value: ["t": self.latestScores[3], "v": v, "a": a, "s": 400.0]))
                                let score = RmScore()
                                score.mapType = 0
                                score.type = "s400"
                                score.score = self.latestScores[3]
                                score.data = data
                                GaikeService.sharedInstance.upload("upload/uploadRecord", parameters: ["duration": score.score, "map_type": 0], datas: ["record": score.archive()]).subscribeNext { (res: GKResult<String>) in
                                    if res.code != 0 {
                                        print(res)
                                    }
                                }.addDisposableTo(self.disposeBag)
                                try! self.realm.write {
                                    self.realm.add(score)
                                }
                            }
                        }

                        if v >= 60 && prevData.v < 60 && prevData.v >= 0.5 {
                            self.keyTime["60"] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 60)
                            if self.latestScores[0] == -1 {
                                self.latestScores[0] = self.keyTime["60"]!
                                self.data.append(RmScoreData(value: ["t": self.latestScores[0], "v": 60, "a": a, "s": s]))
                                self.bestScores[0] = (self.latestScores[0] < self.bestScores[0]) && (self.bestScores[0] != -1) ? self.latestScores[0] : self.bestScores[0]
                                self.dataVCs[0].time = self.time2String(self.showBest ? self.bestScores[0] : self.latestScores[0])
                                let data = List<RmScoreData>()
                                data.appendContentsOf(self.data)
                                let score = RmScore()
                                score.type = "v60"
                                score.score = self.latestScores[0]
                                score.data = data
                                try! self.realm.write {
                                    self.realm.add(score)
                                }
                            }
                        }

                        if v <= 60 && prevData.v > 60 {
                            self.keyTime["60"] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 60)
                        }

                        if v >= 100 && prevData.v < 100 && prevData.v >= 40 {
                            self.keyTime["100"] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 100)
                            if self.latestScores[1] == -1 {
                                self.latestScores[1] = self.keyTime["100"]!
                                self.data.append(RmScoreData(value: ["t": self.latestScores[1], "v": 100, "a": a, "s": s]))
                                self.bestScores[1] = (self.latestScores[1] < self.bestScores[1]) && (self.bestScores[1] != -1) ? self.latestScores[1] : self.bestScores[1]
                                self.dataVCs[1].time = self.time2String(self.showBest ? self.bestScores[1] : self.latestScores[1])
                                let data = List<RmScoreData>()
                                data.appendContentsOf(self.data)
                                let score = RmScore()
                                score.type = "v100"
                                score.score = self.latestScores[1]
                                score.data = data
                                try! self.realm.write {
                                    self.realm.add(score)
                                }
                            }
                        }

                        if v <= 0.1 && a < 0.3 {
                            if let v60 = self.keyTime["60"] where v60 != 0 && prevData.v > 0.1 {
                                let dt = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 0) - v60
                                if self.latestScores[2] == -1 {
                                    self.latestScores[2] = dt
                                    self.bestScores[2] = (self.latestScores[2] < self.bestScores[2]) && (self.bestScores[2] != -1) ? self.latestScores[2] : self.bestScores[2]
                                    self.dataVCs[2].time = self.time2String(self.showBest ? self.bestScores[2] : self.latestScores[2])
                                    let data = List<RmScoreData>()
                                    data.appendContentsOf(self.data)
                                    data.append(RmScoreData(value: ["t": self.latestScores[2], "v": 0.0, "a": a, "s": s]))
                                    let score = RmScore()
                                    score.type = "b60"
                                    score.score = self.latestScores[2]
                                    score.data = data
                                    try! self.realm.write {
                                        self.realm.add(score)
                                    }
                                }
                            }
                            self.stopTimer()
                        }

                        if s != prevData.s {
                            self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s]))
                        }
                    } else {
                        if v >= 40 {
                            self.stopTimer()
                            self.ready = false
                        }
                        self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s]))
                    }
                }
            }
        }
    }

    func stopTimer() {
        UIApplication.sharedApplication().idleTimerDisabled = false
        timerDisposable?.dispose()
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
