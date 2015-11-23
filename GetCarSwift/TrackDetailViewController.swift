//
//  TrackDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import MapKit

class TrackDetailViewController: UIViewController {

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postViewPos: NSLayoutConstraint!

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

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var commentTextField: UITextField!

    let disposeBag = DisposeBag()

    var trackDetailViewModel: TrackDetailViewModel!

    var score1: RmScore?
    var score2: RmScore?
    var score3: RmScore?

    var annotation1: MKPointAnnotation?
    var annotation2: MKPointAnnotation?
    var annotation3: MKPointAnnotation?

    var _timer: Disposable?

    var danmuEffect: DanmuEffect?
    var danmuPlayed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        trackDetailViewModel.viewProxy = self
        initTrackData()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        for button in [button1, button2, button3] {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 23.5
        }

        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.delegate = self
        if let raceTrack = trackDetailViewModel.raceTrack {
            if let mapCenter = raceTrack.mapCenter {
                mapView.setCenterCoordinate(CLLocationCoordinate2DMake(mapCenter.latitude, mapCenter.longitude), zoomLevel: raceTrack.mapZoom, animated: true)
            }
        }

        var danmuRect = self.mapView.frame
        danmuRect.size = CGSize(width: danmuRect.width, height: danmuRect.height / 3 * 2)
        danmuEffect = DanmuEffect(superView: self.view, rect: danmuRect)

    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        _timer?.dispose()
    }

    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
                self.postViewPos.constant = keyboardSize.height
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.25, animations: {
            self.postViewPos.constant = 0
        })
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func initTrackData() {
        self.title = trackDetailViewModel.trackTitle
        trackDetailViewModel.getComments()
        trackDetailViewModel.rx_comments.subscribeNext { comments in
            if !self.danmuPlayed && comments.count > 0 {
                self.danmuPlayed = true
                for comment in comments {
                    self.danmuEffect?.send(comment.content, delay: 1)
                }
            }
        }.addDisposableTo(disposeBag)
    }

    @IBAction func didStart(sender: UIButton) {
        sender.selected = !sender.selected
        _timer?.dispose()
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
            startAnim(annotation1, score: score1)
            startAnim(annotation2, score: score2)
            startAnim(annotation3, score: score3)
        }
    }

    func startAnim(annotation: MKPointAnnotation?, score: RmScore?) {
        if let score = score, annotation = annotation {
            annotation.coordinate = CLLocationCoordinate2DMake(score.data.first?.lat ?? 0, score.data.first?.long ?? 0)
            let view = mapView.viewForAnnotation(annotation)
            let points: [CGPoint] = score.data.map { data in
                let loc = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
                return self.mapView.convertCoordinate(loc, toPointToView: self.mapView)
            }
            let anim = CAKeyframeAnimation(keyPath: "position")
            anim.duration = score.score
            anim.keyTimes = score.data.map { $0.t / score.score }
            anim.values = points.map { NSValue(CGPoint: CGPointMake($0.x - points[0].x, $0.y - points[0].y)) }
            anim.calculationMode = kCAAnimationLinear
            anim.removedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            anim.additive = true
            anim.delegate = self

            view?.layer.addAnimation(anim, forKey: "race")
        }
    }

    @IBAction func didAddPlayer(sender: UIButton) {
        let addViewController = R.storyboard.mine.add_player_popover!
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.type = trackDetailViewModel.trackTitle
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 258)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }

    @IBAction func didPostComment(sender: UIButton) {
        trackDetailViewModel?.postComment(commentTextField.text!).subscribeNext {
            self.danmuEffect?.send(self.commentTextField.text!, highPriority: true)
            self.commentTextField.text = ""
            }.addDisposableTo(disposeBag)
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

extension TrackDetailViewController: AddPlayerDelegate {
    func didPlayerAdded(avatar avatar: UIImage, name: String, score: RmScore, sender: UIButton?) {
        sender?.setBackgroundImage(avatar, forState: .Normal)
        sender?.layer.borderColor = UIColor.gaikeRedColor().CGColor
        sender?.layer.borderWidth = 2

        switch sender {
        case .Some(button1):
            titleLabel1.text = name
            score1 = score
            if annotation1 == nil {
                annotation1 = MKPointAnnotation()
                mapView.addAnnotation(annotation1!)
            }
            if let first = score.data.first {
                annotation1?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
            }
        case .Some(button2):
            titleLabel2.text = name
            score2 = score
            if annotation2 == nil {
                annotation2 = MKPointAnnotation()
                mapView.addAnnotation(annotation2!)
            }
            if let first = score.data.first {
                annotation2?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
            }
        case .Some(button3):
            titleLabel3.text = name
            score3 = score
            if annotation3 == nil {
                annotation3 = MKPointAnnotation()
                mapView.addAnnotation(annotation3!)
            }
            if let first = score.data.first {
                annotation3?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
            }
        default:
            break
        }
    }
}

extension TrackDetailViewController: MKMapViewDelegate {

}