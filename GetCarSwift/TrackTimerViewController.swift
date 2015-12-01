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
    var passFlag = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        updateScore()

        DeviceDataService.sharedInstance.rxAcceleration.subscribeNext { acces in
            if let loc = DeviceDataService.sharedInstance.rxLocation.value {
                let a = acces.averageA()
                self.vLabel.text = String(format: "速度：%05.1f km/h    加速度：%.1f kg/N", loc.speed < 0 ? 0 : loc.speed * 3.6, a)
                if let start = self.raceTrack.startLoc {
                    if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(start.latitude, start.longitude), 15) {
                        if !self.inStartCircle {
                            if self.passFlag == self.raceTrack.passLocs.count {
                                let data = List<RmScoreData>()
                                data.appendContentsOf(self.data)
                                if let score = data.last?.t where score >= 0.5 {
                                    let rmscore = RmScore()
                                    rmscore.type = self.raceTrack.name
                                    rmscore.score = score
                                    rmscore.data = data
                                    rmscore.mapType = self.raceTrack.id
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
                    for rmLoc in self.raceTrack.passLocs {
                        if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(rmLoc.latitude, rmLoc.longitude), 15) {
                            self.passFlag++
                        }
                    }
                    if let leaveLoc = self.raceTrack.leaveLoc {
                        if MACircleContainsCoordinate(loc.coordinate, CLLocationCoordinate2DMake(leaveLoc.latitude, leaveLoc.longitude), 10) {
                            self.stopTimer()
                            self.data.removeAll()
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
    }

    func time2String(t: Double) -> String {
        let ms = Int(round(t * 100 % 100))
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    func updateScore() {
        let scores = realm.objects(RmScore).filter("type = '\(raceTrack.name)'")

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
