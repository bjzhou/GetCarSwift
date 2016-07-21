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

class StraightMatchViewController: UIViewController, CAAnimationDelegate {

    let disposeBag = DisposeBag()

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var titleLabel3: UILabel!

    @IBOutlet weak var vTitleLabel: UILabel!
    @IBOutlet weak var aTitleLabel: UILabel!

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

    var ads: [UIImage?] = [R.image.ad_KW, R.image.ad_AFE, R.image.ad_CSB, R.image.ad_MRG, R.image.ad_DMEN, R.image.ad_JBOM, R.image.ad_TEIN, R.image.ad_INJEN, R.image.ad_ohlins, R.image.ad_DIXCEL, R.image.ad_AP_RACING]

    var trackDetailViewModel = TrackDetailViewModel()
    var danmuEffect: DanmuEffect?

    var timerOffset: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        addEndEditingGesture(self.view)

        trackDetailViewModel.sid = 1000 //FIXME: should be 0

        for button in [button1, button2, button3] {
            button?.layer.masksToBounds = true
            button?.layer.cornerRadius = 23.5
        }

        self.navigationItem.rightBarButtonItem?.image = R.image.nav_item_comment?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.setBackgroundVerticalPositionAdjustment(3, for: .default)

        trackDetailViewModel.getComments().subscribeNext { cs in
            for comment in cs {
                self.danmuEffect?.send(comment.content, delay: 1, highlight: comment.uid == Mine.sharedInstance.id)
            }
            }.addDisposableTo(disposeBag)
    }

    override func viewDidLayoutSubviews() {
        var danmuRect = raceBg.frame
        danmuRect.size = CGSize(width: danmuRect.width, height: danmuRect.height / 2)
        danmuEffect = DanmuEffect(superView: raceBg, rect: danmuRect)
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    override func viewDidDisappear(_ animated: Bool) {
        timerDisposable?.dispose()
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(StraightMatchViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StraightMatchViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo, let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue else {
            return
        }

        self.postViewPos.constant = keyboardSize.height
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.postViewPos.constant = 0
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func didStart(_ sender: UIButton) {
        let stopTime = max(max(score1?.score ?? 0, score2?.score ?? 0), score3?.score ?? 0)
        if stopTime == 0 { return }

        sender.isSelected = !sender.isSelected

        if timerOffset == 0 {
            self.timerDisposable?.dispose()
            self.stopAnim()
            vTitleLabel.text = "速度\nkm/h"
            aTitleLabel.text = "加速度\nm/s^2"
            vLabel1.text = "--"
            vLabel2.text = "--"
            vLabel3.text = "--"
            aLabel1.text = "--"
            aLabel2.text = "--"
            aLabel3.text = "--"

            timerDisposable = Observable<Int>.timer(0, period: 0.01, scheduler: MainScheduler.instance).subscribeNext { _ in
                if !sender.isSelected {
                    return
                }

                self.timerOffset += 1
                let t = Double(self.timerOffset)/100
                let curTs = self.time2String(t)
                self.timeLabel.text = curTs

                if let lt = (self.score1?.data.filter { $0.t <= t })?.last, let gt = (self.score1?.data.filter { $0.t >= t })?.first {
                    self.vLabel1.text = String(format: "%05.1f", lt.t == gt.t ? lt.v : lt.v + (gt.v - lt.v) * (t - lt.t) / (gt.t - lt.t))
                    self.aLabel1.text = String(format: "%.1f", lt.t == gt.t ? lt.a : lt.a + (gt.a - lt.a) * (t - lt.t) / (gt.t - lt.t))
                }

                if let lt = (self.score2?.data.filter { $0.t <= t })?.last, let gt = (self.score2?.data.filter { $0.t >= t })?.first {
                    self.vLabel2.text = String(format: "%05.1f", lt.t == gt.t ? lt.v : lt.v + (gt.v - lt.v) * (t - lt.t) / (gt.t - lt.t))
                    self.aLabel2.text = String(format: "%.1f", lt.t == gt.t ? lt.a : lt.a + (gt.a - lt.a) * (t - lt.t) / (gt.t - lt.t))
                }

                if let lt = (self.score3?.data.filter { $0.t <= t })?.last, let gt = (self.score3?.data.filter { $0.t >= t })?.first {
                    self.vLabel3.text = String(format: "%05.1f", lt.t == gt.t ? lt.v : lt.v + (gt.v - lt.v) * (t - lt.t) / (gt.t - lt.t))
                    self.aLabel3.text = String(format: "%.1f", lt.t == gt.t ? lt.a : lt.a + (gt.a - lt.a) * (t - lt.t) / (gt.t - lt.t))
                }

                self.showRandomAd(self.timerOffset)

                if t >= stopTime {
                    self.timerDisposable?.dispose()
                    sender.isSelected = !sender.isSelected
                    self.stopAnim()
                    self.timerOffset = 0
                }
            }
            raceBg.image = R.image.race_bg_starting
            startAnim(button1, score: score1)
            startAnim(button2, score: score2)
            startAnim(button3, score: score3)
            startFinishLineAnim()
        } else {
            if !sender.isSelected {
                // pause
                pauseAnim()
            } else {
                // resume
                resumeAnim()
            }
        }
    }

    func pauseAnim() {
        button1.superview!.layer.pauseAnimation()
        button2.superview!.layer.pauseAnimation()
        button3.superview!.layer.pauseAnimation()
        finishLine.layer.pauseAnimation()

        if let _ = leftAdImg.layer.animation(forKey: "ad") {
            leftAdImg.layer.pauseAnimation()
        }

        if let _ = rightAdImg.layer.animation(forKey: "ad") {
            rightAdImg.layer.pauseAnimation()
        }
    }

    func resumeAnim() {
        button1.superview!.layer.resumeAnimation()
        button2.superview!.layer.resumeAnimation()
        button3.superview!.layer.resumeAnimation()
        finishLine.layer.resumeAnimation()

        if let _ = leftAdImg.layer.animation(forKey: "ad"), leftAdImg.layer.speed == 0 {
            leftAdImg.layer.resumeAnimation()
        }

        if let _ = rightAdImg.layer.animation(forKey: "ad"), rightAdImg.layer.speed == 0 {
            rightAdImg.layer.resumeAnimation()
        }
    }

    func startAnim(_ button: UIButton, score: RmScore?) {
        guard let score = score else {
            return
        }

        let data = score.data.filter { $0.v != 60 && $0.v != 100 }
        let anim = CAKeyframeAnimation(keyPath: "position.y")
        anim.duration = score.score
        anim.keyTimes = data.map { $0.t / score.score }
        anim.values = data.map { -Double(self.raceBg.frame.height - 23.5) / 400 * $0.s }
        anim.calculationMode = kCAAnimationLinear
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.isAdditive = true
        anim.delegate = self

        button.superview?.layer.add(anim, forKey: "race")
        button.isEnabled = false
    }

    func startFinishLineAnim() {
        var bestScore = RmScore()
        bestScore.score = 99999
        for score in [score1, score2, score3] {
            if let score = score, score.score < bestScore.score {
                bestScore = score
            }
        }
        let data = bestScore.data.filter { $0.v != 60 && $0.v != 100 }
        let anim = CAKeyframeAnimation(keyPath: "position.y")
        anim.duration = bestScore.score
        anim.keyTimes = data.map { $0.t / bestScore.score }
        anim.values = data.map { $0.s }
        anim.calculationMode = kCAAnimationLinear
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.isAdditive = true
        anim.delegate = self

        finishLine.layer.add(anim, forKey: "finishLine")
    }

    func showRandomAd(_ t: Int64) {
        let rdm = arc4random_uniform(1000)
        if rdm < 5 {
            startAdAnim(leftAdImg)
        } else if rdm < 10 {
            startAdAnim(rightAdImg)
        }
    }

    func startAdAnim(_ ad: UIImageView) {
        if let _ = ad.layer.animation(forKey: "ad") {
            return
        }
        let img = ads[Int(arc4random_uniform(11))]
        ad.image = img
        let anim = CABasicAnimation(keyPath: "position.y")
        anim.duration = 5
        anim.fromValue = 0
        anim.toValue = raceBg.frame.height + img!.size.height + 1
        anim.isRemovedOnCompletion = true
        ad.layer.add(anim, forKey: "ad")
    }

    func stopAnim() {
        resumeAnim()
        button1.superview?.layer.removeAllAnimations()
        button2.superview?.layer.removeAllAnimations()
        button3.superview?.layer.removeAllAnimations()
        button1.isEnabled = true
        button2.isEnabled = true
        button3.isEnabled = true
        finishLine.layer.removeAllAnimations()
        raceBg.image = R.image.race_bg
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

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == finishLine.layer.animation(forKey: "finishLine") {
            raceBg.image = R.image.race_bg
        }
    }

    @IBAction func didAddPlayer(_ sender: UIButton) {
        let addViewController = AddPlayerTableViewController()
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.sid = 0
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.present(popupViewController, animated: false, completion: nil)
    }

    @IBAction func didPostComment(_ sender: UIButton) {
        if commentTextField.text!.trim() == "" {
            Toast.makeToast(message: "评论不能为空")
            return
        }
        _ = trackDetailViewModel.postComment(commentTextField.text!).subscribeNext {
            self.danmuEffect?.send(self.commentTextField.text!, highlight: true, highPriority: true)
            self.commentTextField.text = ""
            }
        self.view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.track_comment {
            if let destVc = segue.destinationViewController as? CommentsViewController {
                destVc.trackDetailViewModel = trackDetailViewModel
            }
        }
    }
}

extension StraightMatchViewController: AddPlayerDelegate {
    func didPlayerAdded(_ score: AnyObject, sender: UIButton?) {
        guard let score = score as? RmScore else {
            return
        }
        vTitleLabel.text = "0~60\nkm/h"
        aTitleLabel.text = "0~100\nkm/h"

        timerDisposable?.dispose()
        startButton.isSelected = false
        stopAnim()
        timerOffset = 0

        var url = String(score.headUrl)
        var nickname = String(score.nickname)
        if url == "" {
            url = Mine.sharedInstance.avatarUrl ?? ""
        }
        if nickname == "" {
            nickname = Mine.sharedInstance.nickname ?? ""
        }
        sender?.kf_setBackgroundImageWithURL(URL(string: url)!, forState: .normal, placeholderImage: R.image.avatar)
        sender?.layer.borderColor = UIColor.gaikeRedColor().cgColor
        sender?.layer.borderWidth = 2

        switch sender {
        case .some(button1):
            titleLabel1.text = nickname
            score1 = score
        case .some(button2):
            titleLabel2.text = nickname
            score2 = score
        case .some(button3):
            titleLabel3.text = nickname
            score3 = score
        default:
            break
        }

        vLabel1.text = "--:--.--"
        aLabel1.text = "--:--.--"
        vLabel2.text = "--:--.--"
        aLabel2.text = "--:--.--"
        vLabel3.text = "--:--.--"
        aLabel3.text = "--:--.--"

        var filterdScore1 = score1?.data.filter { $0.v >= 60 }
        var filterdScore2 = score1?.data.filter { $0.v >= 100 }
        var filterdScore3 = score2?.data.filter { $0.v >= 60 }
        var filterdScore4 = score2?.data.filter { $0.v >= 100 }
        var filterdScore5 = score3?.data.filter { $0.v >= 60 }
        var filterdScore6 = score3?.data.filter { $0.v >= 100 }
        filterdScore1?.sort { $0.t < $1.t }
        filterdScore2?.sort { $0.t < $1.t }
        filterdScore3?.sort { $0.t < $1.t }
        filterdScore4?.sort { $0.t < $1.t }
        filterdScore5?.sort { $0.t < $1.t }
        filterdScore6?.sort { $0.t < $1.t }
        if let data = filterdScore1?.first {
            vLabel1.text = time2String(data.t)
        }
        if let data = filterdScore2?.first {
            aLabel1.text = time2String(data.t)
        }

        if let data = filterdScore3?.first {
            vLabel2.text = time2String(data.t)
        }
        if let data = filterdScore4?.first {
            aLabel2.text = time2String(data.t)
        }

        if let data = filterdScore5?.first {
            vLabel3.text = time2String(data.t)
        }
        if let data = filterdScore6?.first {
            aLabel3.text = time2String(data.t)
        }
    }
}
