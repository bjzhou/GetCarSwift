//
//  TrackTimerViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

class TrackTimerViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var scoreBestLabel: UILabel!
    @IBOutlet weak var scoreLastest1Label: UILabel!
    @IBOutlet weak var scoreLastest2Label: UILabel!
    @IBOutlet weak var scoreLastest3Label: UILabel!

    var raceTrack = RmRaceTrack()

    let realm = try! Realm()
    let disposeBag = DisposeBag()
    var timerDisposable: Disposable?
    var startLoc: CLLocation?
    var data = List<RmScoreData>()
    var inStartCircle = false
    var passFlags: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        passFlags = raceTrack.passLocs.map { _ in false }
        updateScore()

        DeviceDataService.sharedInstance.rxAcceleration.subscribeNext { acces in
            if let loc = DeviceDataService.sharedInstance.rxLocation.value {
                let a = acces.averageA()
                self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", loc.speed < 0 ? 0 : loc.speed * 3.6, a)
                if let start = self.raceTrack.startLoc {
                    if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(start.latitude, start.longitude), 10) {
                        if !self.inStartCircle {
                            RmLog.d("enter in start circle")
                            if self.passFlags.reduce(true, combine: { $0 && $1 }) {
                                RmLog.d("passed all locs")
                                let data = List<RmScoreData>()
                                data.appendContentsOf(self.data)
                                if let score = data.last?.t where score >= 0.5 {
                                    let rmscore = RmScore()
                                    rmscore.score = score
                                    rmscore.data = data
                                    rmscore.mapType = self.raceTrack.id
                                    RmLog.d("score: \(score)")
                                    RmLog.d("score data: \(data)")
                                    RmLog.d("uploading data to server...")
                                    Records.uploadRecord(rmscore.mapType, duration: rmscore.score, recordData: rmscore.archive()).subscribeNext { res in
                                        RmLog.d("uploading result: \(res.code), \(res.msg)")
                                        }.addDisposableTo(self.disposeBag)
                                    RmLog.d("saved data to local storage.")
                                    try! self.realm.write {
                                        self.realm.add(rmscore)
                                    }
                                    self.updateScore()
                                }
                            }
                            self.inStartCircle = true
                            self.startLoc = loc
                            self.startTimer()
                        }
                    } else {
                        self.inStartCircle = false
                    }
                    for i in 0..<self.raceTrack.passLocs.count {
                        let rmLoc = self.raceTrack.passLocs[i]
                        if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(rmLoc.latitude, rmLoc.longitude), 18) {
                            if self.passFlags[i] == false {
                                self.passFlags[i] = true
                                RmLog.d("passed \(rmLoc)")
                            }
                        }
                    }
                    if let leaveLoc = self.raceTrack.leaveLoc {
                        if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(leaveLoc.latitude, leaveLoc.longitude), 10) {
                            if self.data.count != 0 {
                                self.stopTimer()
                                self.data.removeAll()
                                RmLog.d("leaving...")
                            }
                        }
                    }
                }
            }
        }.addDisposableTo(disposeBag)
    }

    func startTimer() {
        stopTimer()
        UIApplication.sharedApplication().idleTimerDisabled = true
        self.data.removeAll()
        RmLog.d("start timer")
        timerDisposable = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { t in
            let curTs = self.time2String(Double(t)/100)
            self.timeLabel.text = curTs

            if let loc = DeviceDataService.sharedInstance.rxLocation.value {
                if let startLoc = self.startLoc {
                    let v = loc.speed <= 0 ? 0 : (loc.speed * 3.6)
                    let s = startLoc.distanceFromLocation(loc)
                    let a = DeviceDataService.sharedInstance.rxAcceleration.value.averageA()

                    if let prevData = self.data.last {
                        if s != prevData.s {
                            self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s]))
                        }
                    } else {
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
        passFlags = raceTrack.passLocs.map { _ in false }
        RmLog.d("stop timer")
    }

    func time2String(t: Double) -> String {
        let ms = Int(round(t * 100 % 100))
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    func updateScore() {
        RmLog.d("update score")
        let scores = realm.objects(RmScore).filter("mapType = \(raceTrack.id)")

        if scores.count == 0 {
            Records.getRecord(raceTrack.id, count: 3).subscribeNext { res in
                if let r = res.data {
                    if r.newestRes.count != 0 {
                        for s in r.newestRes {
                            try! self.realm.write {
                                self.realm.add(s, update: true)
                            }
                        }
                        for s in r.bestRes {
                            try! self.realm.write {
                                self.realm.add(s, update: true)
                            }
                        }
                        self.updateScore()
                    }
                }
            }.addDisposableTo(disposeBag)
            return
        }

        let latests = scores.sorted("createdAt", ascending: false)
        if latests.count > 0 {
            scoreLastest1Label.text = time2String(latests[0].score)
        }
        if latests.count > 1 {
            scoreLastest2Label.text = time2String(latests[1].score)
        }
        if latests.count > 2 {
            scoreLastest3Label.text = time2String(latests[2].score)
        }

        let best = scores.sorted("score")
        if best.count > 0 {
            scoreBestLabel.text = time2String(best[0].score)
        }
    }

}
