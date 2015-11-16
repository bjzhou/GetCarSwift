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

    var score1: RmScore?
    var score2: RmScore?
    var score3: RmScore?

    var _timer: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()

        for button in [button1, button2, button3] {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 23.5
        }
    }

    override func viewDidAppear(animated: Bool) {
    }

    override func viewDidDisappear(animated: Bool) {
        _timer?.dispose()
    }

    @IBAction func didStart(sender: UIButton) {
        sender.selected = !sender.selected
        _timer?.dispose()
        stopAnim()
        if sender.selected {
            let stopTime = max(max(score1?.score ?? 0, score2?.score ?? 0), score3?.score ?? 0)
            _timer = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { (t: Int64) in
                let tms = t % 100
                let s = t / 100 % 60
                let m = t / 100 / 60
                self.timeLabel.text = String(format: "%02d:%02d.%02d", arguments: [m, s, tms])

                if let score = self.score1 {
                    let datas = score.data.filter { $0.t == Double(t)/100 }
                    if let data = datas.first {
                        self.vLabel1.text = String(format: "%05.1f", data.v)
                        self.aLabel1.text = String(format: "%.1f", data.a)
                    }
                }

                if let score = self.score2 {
                    let datas = score.data.filter { $0.t == Double(t)/100 }
                    if let data = datas.first {
                        self.vLabel2.text = String(format: "%05.1f", data.v)
                        self.aLabel2.text = String(format: "%.1f", data.a)
                    }
                }

                if let score = self.score3 {
                    let datas = score.data.filter { $0.t == Double(t)/100 }
                    if let data = datas.first {
                        self.vLabel3.text = String(format: "%05.1f", data.v)
                        self.aLabel3.text = String(format: "%.1f", data.a)
                    }
                }

                if Double(t)/100 >= stopTime {
                    self._timer?.dispose()
                    sender.selected = !sender.selected
                }
            }
            startAnim(button1, score: score1)
            startAnim(button2, score: score2)
            startAnim(button3, score: score3)
        }
    }

    func startAnim(button: UIButton, score: RmScore?) {
        if let score = score {
            let anim = CAKeyframeAnimation(keyPath: "position.y")
            anim.duration = score.score
            anim.keyTimes = score.data.map { $0.t }
            anim.values = score.data.map { -Double(self.raceBg.frame.height - 23.5) / 400 * $0.s }
            anim.calculationMode = kCAAnimationPaced
            anim.rotationMode = kCAAnimationRotateAuto
            anim.removedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            anim.additive = true
            anim.delegate = self

            button.superview?.layer.addAnimation(anim, forKey: "race")
        }
    }

    func stopAnim() {
        button1.superview?.layer.removeAllAnimations()
        button2.superview?.layer.removeAllAnimations()
        button3.superview?.layer.removeAllAnimations()
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
