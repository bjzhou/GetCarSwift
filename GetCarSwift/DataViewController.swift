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

    var datas = [UIView]()
    var dataVCs = [DataSubViewController]()
    let dataTitles = ["0~60km/h", "0~100km/h", "100~200km/h", "0~400m"]

    var timerDisposable: Disposable?

    var ready = false

    var startLoc: CLLocation?

    var data = List<RmScoreData>()
    var keyTime = [String:Double]()
    var wrongScore = false

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
        let noSignalImages = [R.image.no_signal_1(), R.image.no_signal_2(), R.image.no_signal_3(), R.image.no_signal_4(), R.image.no_signal_5()]
        let signalImages = [R.image.signal_1(), R.image.signal_2(), R.image.signal_3(), R.image.signal_4(), R.image.signal_5()]
        DeviceDataService.sharedInstance.rxLocation.asObservable().subscribe(onNext: { loc in
            if let loc = loc {
                for i in 0...4 {
                    signalViews[i]?.image = signalImages[i]
                }
                if loc.horizontalAccuracy > 5 {
                    signalViews[4]?.image = noSignalImages[4]
                }
                if loc.horizontalAccuracy > 10 {
                    signalViews[3]?.image = noSignalImages[3]
                }
                if loc.horizontalAccuracy >= 65 {
                    signalViews[2]?.image = noSignalImages[2]
                }
                if loc.horizontalAccuracy > 65 {
                    signalViews[1]?.image = noSignalImages[1]
                }
            } else {
                for i in 0...4 {
                    signalViews[i]?.image = noSignalImages[i]
                }
            }
        }).addDisposableTo(disposeBag)

        DeviceDataService.sharedInstance.rxAcceleration.asObservable().subscribe(onNext: { acces in
            guard let loc = DeviceDataService.sharedInstance.rxLocation.value else {
                return
            }
            let a = acces.averageA()
            self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", loc.speed < 0 ? 0 : loc.speed * 3.6, a)
            if self.ready && (loc.speed > 0 || a >= 0.3) && loc.horizontalAccuracy < 65 {
                self.startLoc = loc
                self.startTimer()
            }
            if loc.speed <= 0.1 && a < 0.3 {
                self.ready = true
                self.timeLabel.text = "00:00.00"
            }
        }).addDisposableTo(disposeBag)
    }

    func initPages() {

        datas = [data0, data1, data2, data3]
        for i in 0 ..< 4 {

            datas[i].layoutIfNeeded()

            let scale: CGFloat = (self.view.frame.height - 410) / 257

            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: datas[i].frame.width, height: 21*scale))
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            titleLabel.font = UIFont.systemFont(ofSize: 14*scale)
            titleLabel.text = dataTitles[i]
            let subVc = DataSubViewController()
            subVc.scale = scale
            subVc.view.frame = CGRect(x: 0, y: 0, width: datas[i].frame.width, height: datas[i].frame.height)
            self.addChildViewController(subVc)
            subVc.didMove(toParentViewController: self)
            dataVCs.append(subVc)
            datas[i].addSubview(titleLabel)
            datas[i].addSubview(subVc.view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        latestScores = [-1, -1, -1, -1]
        bestScores = [-1, -1, -1, -1]
        updateScore()
    }

    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }

    @IBAction func didLatestSelected(_ sender: UIButton) {
        sender.isSelected = true
        bestButton.isSelected = false
        showBest = false
    }

    @IBAction func didBestSelected(_ sender: UIButton) {
        sender.isSelected = true
        latestButton.isSelected = false
        showBest = true
    }

    func time2String(_ t: Double) -> String {
        if t < 0 {
            return "--:--.--"
        }
        let ms = Int(round((t * 100).truncatingRemainder(dividingBy: 100)))
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    func fixS(_ fixScore: Double, dataList: List<RmScoreData>, expectV: Double) -> Double {
        var expectS = dataList.last!.s
        if dataList.count > 1 {
            let dt = fixScore - dataList.last!.t
            if dt != 0 {
                expectS += (expectV - dataList.last!.v) / 3.6 * dt
            }
        }
        return expectS
    }

    func fixScore(_ t: Double, dataList: List<RmScoreData>, v: Double, expectV: Double) -> Double {
        var expectT = 0.0
        if dataList.count > 1 {
            expectT = dataList.last!.t + fixStart(dataList)
            let dt = t - dataList.last!.t
            if dt != 0 {
                let a = (v - dataList.last!.v) / 3.6 / dt
                if a != 0 {
                    var expectDt = (expectV - dataList.last!.v) / 3.6 / a
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

    func fixScore(_ t: Double, dataList: List<RmScoreData>, v: Double, expectS: Double) -> Double {
        var expectT = 0.0
        if dataList.count > 1 {
            expectT = dataList.last!.t + fixStart(dataList)
            let dt = t - dataList.last!.t
            if dt != 0 {
                let a = (v - dataList.last!.v) / 3.6 / dt
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

    func fixStart(_ dataList: List<RmScoreData>) -> Double {
        var i = 0
        for j in 0..<dataList.count {
            if dataList[j].v != 0 {
                i = j
                break
            }
        }
        if i == dataList.count - 1 { return 0 }
        var expectDt = 0.0
        let dtStart = dataList[i+1].t - dataList[i].t
        if dtStart != 0 {
            let a = (dataList[i+1].v - dataList[i].v) / 3.6 / dtStart
            if a > 0 {
                expectDt = dataList[i].v / 3.6 / a - dataList[i].t
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
        let v60s = gRealm?.objects(RmScore.self).filter("mapType = 1001")
        let v100s = gRealm?.objects(RmScore.self).filter("mapType = 1002")
        let s400s = gRealm?.objects(RmScore.self).filter("mapType = 0")
        let v200s = gRealm?.objects(RmScore.self).filter("mapType = 1004")
        self.latestScores[0] =? v60s?.sorted(byProperty: "createdAt").last?.score
        self.bestScores[0] =? v60s?.sorted(byProperty: "score").first?.score
        self.latestScores[1] =? v100s?.sorted(byProperty: "createdAt").last?.score
        self.bestScores[1] =? v100s?.sorted(byProperty: "score").first?.score
        self.latestScores[2] =? v200s?.sorted(byProperty: "createdAt").last?.score
        self.bestScores[2] =? v200s?.sorted(byProperty: "score").first?.score
        self.latestScores[3] =? s400s?.sorted(byProperty: "createdAt").last?.score
        self.bestScores[3] =? s400s?.sorted(byProperty: "score").first?.score

        if v60s?.count == 0 {
            updateFromNet(1001)
        }

        if v100s?.count == 0 {
            updateFromNet(1002)
        }

        if s400s?.count == 0 {
            updateFromNet(0)
        }

        if v200s?.count == 0 {
            updateFromNet(1004)
        }

        for i in 0...3 {
            dataVCs[i].time = self.time2String(showBest ? bestScores[i] : latestScores[i])
        }
    }

    func updateFromNet(_ mapType: Int) {
        Records.getRecord(mapType, count: 1).subscribe(onNext: { res in
            guard let r = res.data else {
                return
            }
            if r.newestRes.count != 0 {
                for s in r.newestRes {
                    gRealm?.writeOptional {
                        gRealm?.add(s, update: true)
                    }
                }
                for s in r.bestRes {
                    gRealm?.writeOptional {
                        gRealm?.add(s, update: true)
                    }
                }
                self.updateScore()
            }
            }).addDisposableTo(disposeBag)
    }

    func startTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
        self.data.removeAll()
        self.keyTime.removeAll()
        self.ready = false
        self.wrongScore = false
        self.latestScores = [-1.0, -1.0, -1.0, -1.0]
        timerDisposable?.dispose()
        timerDisposable = Observable<Int>.timer(0, period: 0.01, scheduler: MainScheduler.instance).subscribe(onNext: { t in
            let curTs = self.time2String(Double(t)/100)
            self.timeLabel.text = curTs

            guard let loc = DeviceDataService.sharedInstance.rxLocation.value, let startLoc = self.startLoc, loc.horizontalAccuracy < 65 else {
                self.stopTimer()
                self.timeLabel.text = "  信号丢失  "
                self.ready = false
                return
            }

            var v = loc.speed <= 0 ? 0 : (loc.speed * 3.6)
            let s = startLoc.distance(from: loc)
            let a = DeviceDataService.sharedInstance.rxAcceleration.value.averageA()

            guard let prevData = self.data.last else {
                if v >= 40 {
                    self.stopTimer()
                    self.ready = false
                }
                self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s]))
                return
            }

            if self.data.endIndex > 1 {
                let prevA = (self.data[self.data.endIndex-1].v - self.data[self.data.endIndex-2].v) / 3.6 / (self.data[self.data.endIndex-1].t - self.data[self.data.endIndex-2].t)
                let calcV = prevData.v + prevA * (Double(t)/100 - prevData.t) * 3.6
                if v == 0 && calcV > 10 {
                    v = calcV
                }
            }

            if s >= 400 && prevData.s < 400 && prevData.s > 200 && !self.wrongScore {
                if self.latestScores[3] == -1 {
                    self.latestScores[3] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectS: 400)
                    self.bestScores[3] = (self.latestScores[3] < self.bestScores[3]) && (self.bestScores[3] != -1) ? self.latestScores[3] : self.bestScores[3]
                    self.dataVCs[3].time = self.time2String(self.showBest ? self.bestScores[3] : self.latestScores[3])
                    let data = List<RmScoreData>()
                    data.append(objectsIn: self.data)
                    data.append(RmScoreData(value: ["t": self.latestScores[3], "v": v, "a": a, "s": 400.0]))
                    let score = RmScore()
                    score.mapType = 0
                    score.score = self.latestScores[3]
                    score.data = data
                    Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribe(onNext: { res in
                        RmLog.v("upload \(score)")
                        }).addDisposableTo(self.disposeBag)
                    gRealm?.writeOptional {
                        gRealm?.add(score)
                    }
                }
            }

            if v >= 60 && prevData.v < 60 && prevData.v >= 0.5 && !self.wrongScore {
                self.keyTime["60"] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 60)
                if self.keyTime["60"] ?? 0 < 1.2 {
                    self.wrongScore = true
                }
                if self.latestScores[0] == -1 {
                    self.latestScores[0] = self.keyTime["60"]!
                    self.data.append(RmScoreData(value: ["t": self.latestScores[0], "v": 60, "a": a, "s": self.fixS(self.keyTime["60"]!, dataList: self.data, expectV: 60)]))
                    self.bestScores[0] = (self.latestScores[0] < self.bestScores[0]) && (self.bestScores[0] != -1) ? self.latestScores[0] : self.bestScores[0]
                    self.dataVCs[0].time = self.time2String(self.showBest ? self.bestScores[0] : self.latestScores[0])
                    let data = List<RmScoreData>()
                    data.append(objectsIn: self.data)
                    let score = RmScore()
                    score.mapType = 1001
                    score.score = self.latestScores[0]
                    score.data = data
                    Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribe(onNext: { res in
                        RmLog.v("upload \(score)")
                        }).addDisposableTo(self.disposeBag)
                    gRealm?.writeOptional {
                        gRealm?.add(score)
                    }
                }
            }

            if v >= 100 && prevData.v < 100 && prevData.v >= 40 && !self.wrongScore {
                self.keyTime["100"] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 100)
                if self.keyTime["100"] ?? 0 < 2.5 {
                    self.wrongScore = true
                }
                if self.latestScores[1] == -1 {
                    self.latestScores[1] = self.keyTime["100"]!
                    self.data.append(RmScoreData(value: ["t": self.latestScores[1], "v": 100, "a": a, "s": self.fixS(self.keyTime["100"]!, dataList: self.data, expectV: 100)]))
                    self.bestScores[1] = (self.latestScores[1] < self.bestScores[1]) && (self.bestScores[1] != -1) ? self.latestScores[1] : self.bestScores[1]
                    self.dataVCs[1].time = self.time2String(self.showBest ? self.bestScores[1] : self.latestScores[1])
                    let data = List<RmScoreData>()
                    data.append(objectsIn: self.data)
                    let score = RmScore()
                    score.mapType = 1002
                    score.score = self.latestScores[1]
                    score.data = data
                    Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribe(onNext: { res in
                        RmLog.v("upload \(score)")
                        }).addDisposableTo(self.disposeBag)
                    gRealm?.writeOptional {
                        gRealm?.add(score)
                    }
                }
            }

            if v >= 200 && prevData.v < 200 && !self.wrongScore {
                self.keyTime["200"] = self.fixScore(Double(t)/100, dataList: self.data, v: v, expectV: 200)
                if self.latestScores[2] == -1 {
                    if let keyTime100 = self.keyTime["100"], self.keyTime["200"]! - keyTime100 > 0 {
                        self.latestScores[2] = self.keyTime["200"]! - keyTime100
                        self.data.append(RmScoreData(value: ["t": self.latestScores[2], "v": 200, "a": a, "s": self.fixS(self.keyTime["200"]!, dataList: self.data, expectV: 200)]))
                        self.bestScores[2] = (self.latestScores[2] < self.bestScores[2]) && (self.bestScores[2] != -1) ? self.latestScores[2] : self.bestScores[2]
                        self.dataVCs[2].time = self.time2String(self.showBest ? self.bestScores[2] : self.latestScores[2])
                        let data = List<RmScoreData>()
                        data.append(objectsIn: self.data)
                        let score = RmScore()
                        score.mapType = 1004
                        score.score = self.latestScores[2]
                        score.data = data
                        Records.uploadRecord(score.mapType, duration: score.score, recordData: score.archive()).subscribe(onNext: { res in
                            RmLog.v("upload \(score)")
                            }).addDisposableTo(self.disposeBag)
                        gRealm?.writeOptional {
                            gRealm?.add(score)
                        }
                    }
                }
            }

            if v <= 0.1 && a < 0.3 {
                self.stopTimer()
            }

            if s != prevData.s {
                self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s]))
            }
        })
    }

    func stopTimer() {
        UIApplication.shared.isIdleTimerDisabled = false
        timerDisposable?.dispose()
        self.timeLabel.text = "00:00.00"
        self.ready = true
    }

}

class DataSubViewController: UIViewController {

    let label = UILabel()
    var scale: CGFloat = 1
    var time = "--:--.--" {
        didSet {
            label.text = time
        }
    }

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.clear
    }

    override func viewDidLayoutSubviews() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 30 * scale)
        label.text = time
        self.view.addSubview(label)

        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
