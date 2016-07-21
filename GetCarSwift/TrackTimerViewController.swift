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

    let disposeBag = DisposeBag()
    var timerDisposable: Disposable?
    var startLoc: CLLocation?
    var data = List<RmScoreData>()
    var inStartCircle = false
    var passFlag = false

    override func viewDidLoad() {
        super.viewDidLoad()

        updateScore()

        passFlag = false
        DeviceDataService.sharedInstance.rxAcceleration.asObservable().subscribeNext { acces in
            guard let loc = DeviceDataService.sharedInstance.rxLocation.value else {
                return
            }

            let a = acces.averageA()
            self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", loc.speed < 0 ? 0 : loc.speed * 3.6, a)

            guard let start = self.raceTrack.startLoc else {
                return
            }

            if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(start.latitude, start.longitude), 13) {
                RmLog.d("is in start circle \(self.inStartCircle)")
                if self.inStartCircle { return }
                RmLog.d("enter in start circle: \(self.passFlag)")
                if self.passFlag {
                    RmLog.d("passed all locs")
                    let data = List<RmScoreData>()
                    data.append(objectsIn: self.data)
                    if let score = data.last?.t, score >= 0.5 {
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
                        gRealm?.writeOptional {
                            gRealm?.add(rmscore)
                        }
                        RmLog.d("saved data to local storage.")
                        self.updateScore()
                    }
                }
                self.inStartCircle = true
                self.startLoc = loc
                self.startTimer()
            } else {
                self.inStartCircle = false
            }

            for i in 0..<self.raceTrack.passLocs.count {
                let rmLoc = self.raceTrack.passLocs[i]
                if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(rmLoc.latitude, rmLoc.longitude), 15) {
                    if !self.passFlag {
                        self.passFlag = true
                        RmLog.d("passed \(rmLoc)")
                    }
                }
            }

            if let leaveLoc = self.raceTrack.leaveLoc, MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(leaveLoc.latitude, leaveLoc.longitude), 15) {
                if self.data.count != 0 {
                    self.stopTimer()
                    self.data.removeAll()
                    RmLog.d("leaving...")
                }
            }
        }.addDisposableTo(disposeBag)
    }

    func startTimer() {
        stopTimer()
        UIApplication.shared().isIdleTimerDisabled = true
        self.data.removeAll()
        RmLog.d("start timer")
        timerDisposable = Observable<Int>.timer(0, period: 0.01, scheduler: MainScheduler.instance).subscribeNext { t in
            let curTs = self.time2String(Double(t)/100)
            self.timeLabel.text = curTs

            guard let loc = DeviceDataService.sharedInstance.rxLocation.value, let startLoc = self.startLoc else {
                return
            }

            let v = loc.speed <= 0 ? 0 : (loc.speed * 3.6)
            let s = startLoc.distance(from: loc)
            let a = DeviceDataService.sharedInstance.rxAcceleration.value.averageA()

            if let prevData = self.data.last {
                if s != prevData.s {
                    self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s, "lat": loc.coordinate.latitude, "long": loc.coordinate.longitude]))
                }
            } else {
                self.data.append(RmScoreData(value: ["t": Double(t)/100, "v": v, "a": a, "s": s, "lat": loc.coordinate.latitude, "long": loc.coordinate.longitude]))
            }
        }
    }

    func stopTimer() {
        UIApplication.shared().isIdleTimerDisabled = false
        timerDisposable?.dispose()
        self.timeLabel.text = "00:00.00"
        passFlag = false
        RmLog.d("stop timer")
    }

    func time2String(_ t: Double) -> String {
        let ms = Int(round((t * 100).truncatingRemainder(dividingBy: 100)))
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    func updateScore() {
        RmLog.d("update score")
        let scores = gRealm?.allObjects(ofType: RmScore.self).filter(using: "mapType = \(raceTrack.id)")

        if scores?.count == 0 {
            Records.getRecord(raceTrack.id, count: 3).subscribeNext { res in
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
            }.addDisposableTo(disposeBag)
            return
        }

        let latests = scores?.sorted(onProperty: "createdAt", ascending: false)
        if latests?.count > 0 {
            scoreLastest1Label.text = time2String(latests![0].score)
        }
        if latests?.count > 1 {
            scoreLastest2Label.text = time2String(latests![1].score)
        }
        if latests?.count > 2 {
            scoreLastest3Label.text = time2String(latests![2].score)
        }

        let best = scores?.sorted(onProperty: "score")
        if best?.count > 0 {
            scoreBestLabel.text = time2String(best![0].score)
        }
    }

}
