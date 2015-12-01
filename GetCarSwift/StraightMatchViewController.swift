//
//  StraightMatchViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class StraightMatchViewController: UIViewController {

    let disposeBag = DisposeBag()

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

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postViewPos: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: UITextField!

    var score1: RmScore?
    var score2: RmScore?
    var score3: RmScore?

    var timerDisposable: Disposable?

    var ads: [UIImage?] = [R.image.ad_KW, R.image.ad_AFE, R.image.ad_CSB, R.image.ad_MRG, R.image.ad_DMEN, R.image.ad_JBOM, R.image.ad_TEIN, R.image.ad_INJEN, R.image.ad_DHLINS, R.image.ad_DIXCEL, R.image.ad_AP_RACING]

    var trackDetailViewModel = TrackDetailViewModel()
    var danmuEffect: DanmuEffect?
    var danmuPlayed = false

    override func viewDidLoad() {
        super.viewDidLoad()


        var danmuRect = raceBg.frame
        danmuRect.size = CGSize(width: danmuRect.width, height: danmuRect.height / 2)
        danmuEffect = DanmuEffect(superView: raceBg, rect: danmuRect)
        trackDetailViewModel.sid = 0

        for button in [button1, button2, button3] {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 23.5
        }

        self.navigationItem.rightBarButtonItem?.image = R.image.nav_item_comment?.imageWithRenderingMode(.AlwaysOriginal)

        trackDetailViewModel.getComments()
        trackDetailViewModel.rxComments.subscribeNext { comments in
            if !self.danmuPlayed && comments.count > 0 {
                self.danmuPlayed = true
                for comment in comments {
                    self.danmuEffect?.send(comment.content, delay: 1, highlight: comment.uid == Mine.sharedInstance.id)
                }
            }
            }.addDisposableTo(disposeBag)
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
                let curTs = self.time2String(Double(t)/100)
                self.timeLabel.text = curTs

                self.showRandomAd(t)

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
            anim.keyTimes = score.data.map { $0.t / score.score }
            anim.values = score.data.map { -Double(self.raceBg.frame.height - 23.5) / 400 * $0.s }
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
        anim.keyTimes = bestScore.data.map { $0.t / bestScore.score }
        anim.values = bestScore.data.map { $0.s }
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

    func time2String(t: Double) -> String {
        if t < 0 {
            return "--:--.--"
        }
        let ms = Int(round(t * 100 % 100))
        let s = Int(t) % 60
        let m = Int(t) / 60
        return String(format: "%02d:%02d.%02d", arguments: [m, s, ms])
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if anim == finishLine.layer.animationForKey("finishLine") {
            raceBg.image = R.image.race_bg
        }
    }

    @IBAction func didAddPlayer(sender: UIButton) {
        let addViewController = AddPlayerTableViewController()
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.sid = 0
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 200)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }

    @IBAction func didPostComment(sender: UIButton) {
        _ = trackDetailViewModel.postComment(commentTextField.text!).subscribeNext {
            self.danmuEffect?.send(self.commentTextField.text!, highlight: true, highPriority: true)
            self.commentTextField.text = ""
            }
        self.view.endEditing(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.track_comment {
            if let destVc = segue.destinationViewController as? CommentsViewController {
                destVc.trackDetailViewModel = trackDetailViewModel
            }
        }
    }
}

extension StraightMatchViewController: AddPlayerDelegate {
    func didPlayerAdded(score: RmScore, sender: UIButton?) {
        var url = score.headUrl
        var nickname = score.nickname
        if url == "" {
            url = Mine.sharedInstance.avatarUrl ?? ""
        }
        if nickname == "" {
            nickname = Mine.sharedInstance.nickname ?? ""
        }
        sender?.kf_setBackgroundImageWithURL(NSURL(string: url)!, forState: .Normal)
        sender?.layer.borderColor = UIColor.gaikeRedColor().CGColor
        sender?.layer.borderWidth = 2

        var v60 = "00:00.00"
        var v100 = "00:00.00"
        let v60s = score.data.filter { $0.v >= 60 }.sort { $0.0.t < $0.1.t }
        if let data = v60s.first {
            v60 = time2String(data.t)
        }
        let v100s = score.data.filter { $0.v >= 100 }.sort { $0.0.t < $0.1.t }
        if let data = v100s.first {
            v100 = time2String(data.t)
        }

        switch sender {
        case .Some(button1):
            titleLabel1.text = nickname
            score1 = score
            vLabel1.text = v60
            aLabel1.text = v100
        case .Some(button2):
            titleLabel2.text = nickname
            score2 = score
            vLabel2.text = v60
            aLabel2.text = v100
        case .Some(button3):
            titleLabel3.text = nickname
            score3 = score
            vLabel3.text = v60
            aLabel3.text = v100
        default:
            break
        }
    }
}
