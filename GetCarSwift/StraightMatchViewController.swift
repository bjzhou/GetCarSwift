//
//  StraightMatchViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class StraightMatchViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var titleLabel3: UILabel!

    @IBOutlet weak var vLabel1: UILabel!
    @IBOutlet weak var vLabel2: UILabel!
    @IBOutlet weak var vLabel3: UILabel!

    @IBOutlet weak var aLabel1: UILabel!
    @IBOutlet weak var aLabel2: UILabel!
    @IBOutlet weak var aLabel3: UILabel!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var raceBg: UIImageView!
    @IBOutlet weak var finishLine: UIImageView!
    @IBOutlet weak var leftAdImg: UIImageView!
    @IBOutlet weak var rightAdImg: UIImageView!

    var score1: RmScore?
    var score2: RmScore?
    var score3: RmScore?

    var timerDisposable: Disposable?

    var ads: [UIImage?] = [R.image.ad_KW, R.image.ad_AFE, R.image.ad_CSB, R.image.ad_MRG, R.image.ad_DMEN, R.image.ad_JBOM, R.image.ad_TEIN, R.image.ad_INJEN, R.image.ad_DHLINS, R.image.ad_DIXCEL, R.image.ad_AP_RACING]

    override func viewDidLoad() {
        super.viewDidLoad()

        for button in [button1, button2, button3] {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 23.5
        }

        leftAdImg.transform = CGAffineTransformMakeRotation(CGFloat(270.0*M_PI/180.0))
        rightAdImg.transform = CGAffineTransformMakeRotation(CGFloat(90*M_PI/180.0))
    }

    override func viewDidAppear(animated: Bool) {
    }

    override func viewDidDisappear(animated: Bool) {
        timerDisposable?.dispose()
    }

    @IBAction func didStart(sender: UIButton) {
        sender.selected = !sender.selected
        timerDisposable?.dispose()
        stopAnim()
        if sender.selected {
            let stopTime = max(max(score1?.score ?? 0, score2?.score ?? 0), score3?.score ?? 0)
            timerDisposable = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { (t: Int64) in
                let tms = t % 100
                let s = t / 100 % 60
                let m = t / 100 / 60
                self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

                self.showRandomAd(t)

                if let score = self.score1 {
                    let datas = score.record.filter { $0.t == Double(t)/100 }
                    if let data = datas.first {
                        self.vLabel1.text = String(format: "%05.1f", data.v)
                        self.aLabel1.text = String(format: "%.1f", data.a)
                    }
                }

                if let score = self.score2 {
                    let datas = score.record.filter { $0.t == Double(t)/100 }
                    if let data = datas.first {
                        self.vLabel2.text = String(format: "%05.1f", data.v)
                        self.aLabel2.text = String(format: "%.1f", data.a)
                    }
                }

                if let score = self.score3 {
                    let datas = score.record.filter { $0.t == Double(t)/100 }
                    if let data = datas.first {
                        self.vLabel3.text = String(format: "%05.1f", data.v)
                        self.aLabel3.text = String(format: "%.1f", data.a)
                    }
                }

                if Double(t)/100 >= stopTime {
                    self.timerDisposable?.dispose()
                    sender.selected = !sender.selected
                    self.stopAnim()
                }
            }
            raceBg.image = R.image.race_bg_starting
            startAnim(button1, score: score1)
            startAnim(button2, score: score2)
            startAnim(button3, score: score3)
            startFinishLineAnim()
        }
    }

    func startAnim(button: UIButton, score: RmScore?) {
        if let score = score {
            let anim = CAKeyframeAnimation(keyPath: "position.y")
            anim.duration = score.score
            anim.keyTimes = score.record.map { $0.t / score.score }
            anim.values = score.record.map { -Double(self.raceBg.frame.height - 23.5) / 400 * $0.s }
            anim.calculationMode = kCAAnimationLinear
            anim.removedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            anim.additive = true
            anim.delegate = self

            button.superview?.layer.addAnimation(anim, forKey: "race")
        }
    }

    func startFinishLineAnim() {
        var bestScore = RmScore()
        bestScore.score = 99999
        for score in [score1, score2, score3] {
            if let score = score where score.score < bestScore.score {
                bestScore = score
            }
        }
        let anim = CAKeyframeAnimation(keyPath: "position.y")
        anim.duration = bestScore.score
        anim.keyTimes = bestScore.record.map { $0.t / bestScore.score }
        anim.values = bestScore.record.map { $0.s }
        anim.calculationMode = kCAAnimationLinear
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.additive = true
        anim.delegate = self

        finishLine.layer.addAnimation(anim, forKey: "finishLine")
    }

    func showRandomAd(t: Int64) {
        let rdm = random() % 1000
        if rdm < 5 {
            startAdAnim(leftAdImg)
        } else if rdm < 10 {
            startAdAnim(rightAdImg)
        }
    }

    func startAdAnim(ad: UIImageView) {
        if let _ = ad.layer.animationForKey("ad") {
            return
        }
        let img = ads[random() % 11]
        ad.image = img
        let anim = CABasicAnimation(keyPath: "position.y")
        anim.duration = 2
        anim.fromValue = 0
        anim.toValue = raceBg.frame.height + ad.frame.height + 1
        anim.removedOnCompletion = true
        ad.layer.addAnimation(anim, forKey: "ad")
    }

    func stopAnim() {
        button1.superview?.layer.removeAllAnimations()
        button2.superview?.layer.removeAllAnimations()
        button3.superview?.layer.removeAllAnimations()
        finishLine.layer.removeAllAnimations()
        raceBg.image = R.image.race_bg
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if anim == finishLine.layer.animationForKey("finishLine") {
            raceBg.image = R.image.race_bg
        }
    }

    @IBAction func didAddPlayer(sender: UIButton) {
        let addViewController = R.storyboard.mine.add_player_popover!
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.type = "s400"
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 258)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }
}

extension StraightMatchViewController: AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String, score: RmScore, sender: UIButton?) {
        sender?.setBackgroundImage(avatar, forState: .Normal)
        sender?.layer.borderColor = UIColor.gaikeRedColor().CGColor
        sender?.layer.borderWidth = 2

        switch sender {
        case .Some(button1):
            titleLabel1.text = name
            score1 = score
        case .Some(button2):
            titleLabel2.text = name
            score2 = score
        case .Some(button3):
            titleLabel3.text = name
            score3 = score
        default:
            break
        }
    }
}
