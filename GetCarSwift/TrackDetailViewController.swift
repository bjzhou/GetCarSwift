//
//  TrackDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

class TrackDetailViewController: UIViewController {

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postViewPos: NSLayoutConstraint!
    @IBOutlet weak var commentTextField: UITextField!

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

    @IBOutlet weak var mapView: MAMapView!


    let disposeBag = DisposeBag()

    var trackDetailViewModel: TrackDetailViewModel!

    var score1: RmScore?
    var score2: RmScore?
    var score3: RmScore?

    var annotation1: MAPointAnnotation?
    var annotation2: MAPointAnnotation?
    var annotation3: MAPointAnnotation?

    var timerDisposable: Disposable?
    var timerOffset: Int64 = 0

    var danmuEffect: DanmuEffect?

    override func viewDidLoad() {
        super.viewDidLoad()

        trackDetailViewModel.viewProxy = self
        initTrackData()

        addEndEditingGesture(self.view)

        for button in [button1, button2, button3] {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 23.5
        }

        self.navigationItem.rightBarButtonItem?.image = R.image.nav_item_comment?.imageWithRenderingMode(.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem?.setBackgroundVerticalPositionAdjustment(3, forBarMetrics: .Default)

        mapView.showsCompass = false
        mapView.zoomEnabled = true
        mapView.scrollEnabled = false
        mapView.showsLabels = false
        mapView.skyModelEnable = false
        //mapView.mapType = .Satellite
        mapView.delegate = self
        if let raceTrack = trackDetailViewModel.raceTrack, mapCenter = raceTrack.mapCenter {
            mapView.zoomLevel = raceTrack.mapZoom
            mapView.setCenterCoordinate(CLLocationCoordinate2DMake(mapCenter.latitude, mapCenter.longitude), animated: false)

//            mapView.addOverlay(MACircle(centerCoordinate: CLLocationCoordinate2DMake(raceTrack.startLoc?.latitude ?? 0, raceTrack.startLoc?.longitude ?? 0), radius: 10))
//
//            for pass in raceTrack.passLocs {
//                mapView.addOverlay(MACircle(centerCoordinate: CLLocationCoordinate2DMake(pass.latitude, pass.longitude), radius: 18))
//            }

//            annotation1 = MAPointAnnotation()
//            annotation1!.coordinate = CLLocationCoordinate2DMake(raceTrack.startLoc?.latitude ?? 0, raceTrack.startLoc?.longitude ?? 0)
//            mapView.addAnnotation(annotation1)
//            score1 = RmScore()
//            score1?.score = 5
//            let datas = List<RmScoreData>()
//            datas.append(RmScoreData(value: ["t": 0, "v": 0, "a": 1, "lat": annotation1!.coordinate.latitude, "long": annotation1!.coordinate.longitude]))
//            for i in 0...3 {
//                datas.append(RmScoreData(value: ["t": i+1, "v": 60, "a": 1, "lat": raceTrack.passLocs[i].latitude, "long": raceTrack.passLocs[i].longitude]))
//            }
//            datas.append(RmScoreData(value: ["t": 5, "v": 30, "a": 1, "lat": annotation1!.coordinate.latitude, "long": annotation1!.coordinate.longitude]))
//            score1?.data = datas
//
//            annotation2 = MAPointAnnotation()
//            annotation2!.coordinate = CLLocationCoordinate2DMake((raceTrack.startLoc?.latitude ?? 0), raceTrack.startLoc?.longitude ?? 0)
//            mapView.addAnnotation(annotation2)
//            score2 = RmScore()
//            score2?.score = 8
//            let datas2 = List<RmScoreData>()
//            datas2.append(RmScoreData(value: ["t": 0, "v": 0, "a": 1, "lat": annotation2!.coordinate.latitude, "long": annotation2!.coordinate.longitude]))
//            for i in 0...3 {
//                datas2.append(RmScoreData(value: ["t": i+2, "v": 50, "a": 0.8, "lat": raceTrack.passLocs[i].latitude, "long": raceTrack.passLocs[i].longitude]))
//            }
//            datas2.append(RmScoreData(value: ["t": 8, "v": 30, "a": 1, "lat": annotation2!.coordinate.latitude, "long": annotation2!.coordinate.longitude]))
//            score2?.data = datas2
//
//            annotation3 = MAPointAnnotation()
//            annotation3!.coordinate = CLLocationCoordinate2DMake((raceTrack.startLoc?.latitude ?? 0), raceTrack.startLoc?.longitude ?? 0)
//            mapView.addAnnotation(annotation3)
//            score3 = RmScore()
//            score3?.score = 6
//            let datas3 = List<RmScoreData>()
//            datas3.append(RmScoreData(value: ["t": 0, "v": 0, "a": 1, "lat": annotation3!.coordinate.latitude, "long": annotation3!.coordinate.longitude]))
//            for i in 0...3 {
//                datas3.append(RmScoreData(value: ["t": Double(i)+1.5, "v": 50, "a": 0.8, "lat": raceTrack.passLocs[i].latitude, "long": raceTrack.passLocs[i].longitude]))
//            }
//            datas3.append(RmScoreData(value: ["t": 6, "v": 30, "a": 1, "lat": annotation3!.coordinate.latitude, "long": annotation3!.coordinate.longitude]))
//            score3?.data = datas3
        }
    }

    override func viewDidLayoutSubviews() {
        var danmuRect = self.mapView.frame
        danmuRect.size = CGSize(width: danmuRect.width, height: danmuRect.height / 3 * 2)
        danmuEffect = DanmuEffect(superView: self.view, rect: danmuRect)
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        timerDisposable?.dispose()
    }

    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue else {
            return
        }

        self.postViewPos.constant = keyboardSize.height
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
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
        self.title = trackDetailViewModel.raceTrack?.name ?? ""
        trackDetailViewModel.getComments().subscribeNext { comments in
            for comment in comments {
                self.danmuEffect?.send(comment.content, delay: 1, highlight: comment.uid == Mine.sharedInstance.id)
            }
            }.addDisposableTo(disposeBag)
    }

    @IBAction func didStart(sender: UIButton) {
        let stopTime = max(max(score1?.score ?? 0, score2?.score ?? 0), score3?.score ?? 0)
        if stopTime == 0 { return }

        sender.selected = !sender.selected
        if self.timerOffset == 0 {
            timerDisposable?.dispose()
            mapView.zoomEnabled = false
            mapView.rotateEnabled = false
            mapView.rotateCameraEnabled = false
            timerDisposable = timer(0, 0.01, MainScheduler.sharedInstance).subscribeNext { _ in
                if !sender.selected {
                    return
                }

                self.timerOffset++
                let curTs = self.time2String(Double(self.timerOffset)/100)
                self.timeLabel.text = curTs

                if let score = self.score1, data = (score.data.filter { $0.t == Double(self.timerOffset)/100 }).first {
                    self.vLabel1.text = String(format: "%05.1f", data.v)
                    self.aLabel1.text = String(format: "%.1f", data.a)
                }

                if let score = self.score2, data = (score.data.filter { $0.t == Double(self.timerOffset)/100 }).first {
                    self.vLabel2.text = String(format: "%05.1f", data.v)
                    self.aLabel2.text = String(format: "%.1f", data.a)
                }

                if let score = self.score3, data = (score.data.filter { $0.t == Double(self.timerOffset)/100 }).first {
                    self.vLabel3.text = String(format: "%05.1f", data.v)
                    self.aLabel3.text = String(format: "%.1f", data.a)
                }

                if Double(self.timerOffset)/100 >= stopTime {
                    self.timerDisposable?.dispose()
                    sender.selected = !sender.selected
                    self.timerOffset = 0
                    self.mapView.zoomEnabled = true
                    self.mapView.rotateEnabled = true
                    self.mapView.rotateCameraEnabled = true
                }
            }
            startAnim(annotation1, score: score1)
            startAnim(annotation2, score: score2)
            startAnim(annotation3, score: score3)
        } else {
            if !sender.selected {
                // pause
                mapView.viewForAnnotation(annotation1).layer.pauseAnimation()
                mapView.viewForAnnotation(annotation2).layer.pauseAnimation()
                mapView.viewForAnnotation(annotation3).layer.pauseAnimation()
            } else {
                // resume
                mapView.viewForAnnotation(annotation1).layer.resumeAnimation()
                mapView.viewForAnnotation(annotation2).layer.resumeAnimation()
                mapView.viewForAnnotation(annotation3).layer.resumeAnimation()
            }
        }
    }

    func startAnim(annotation: MAPointAnnotation?, score: RmScore?) {
        guard let score = score, annotation = annotation else {
            return
        }

        annotation.coordinate = CLLocationCoordinate2DMake(score.data.first?.lat ?? 0, score.data.first?.long ?? 0)
        let view = mapView.viewForAnnotation(annotation)
        let points: [CGPoint] = score.data.map { data in
            let loc = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
            return self.mapView.convertCoordinate(loc, toPointToView: self.mapView)
        }
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.duration = score.score
        anim.keyTimes = score.data.map { $0.t / score.score }
        anim.values = points.map { NSValue(CGPoint: CGPoint(x: $0.x - points[0].x, y: $0.y - points[0].y)) }
        anim.calculationMode = kCAAnimationLinear
        anim.removedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.additive = true
        anim.delegate = self

        view?.layer.addAnimation(anim, forKey: "race")
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

    @IBAction func didAddPlayer(sender: UIButton) {
        let addViewController = AddPlayerTableViewController()
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.sid = trackDetailViewModel.sid
        addViewController.view.frame = CGRect(x: 0, y: 0, width: 275, height: 200)
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.presentViewController(popupViewController, animated: false, completion: nil)
    }

    @IBAction func didPostComment(sender: UIButton) {
        if commentTextField.text!.trim() == "" {
            self.view.makeToast(message: "评论不能为空")
            return
        }
        trackDetailViewModel?.postComment(commentTextField.text!).subscribeNext {
            self.danmuEffect?.send(self.commentTextField.text!, highlight: true, highPriority: true)
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
    func didPlayerAdded(score: AnyObject, sender: UIButton?) {
        guard let score = score as? RmScore else {
            return
        }
        var url = score.headUrl
        var nickname = score.nickname
        if url == "" {
            url = Mine.sharedInstance.avatarUrl ?? ""
        }
        if nickname == "" {
            nickname = Mine.sharedInstance.nickname ?? ""
        }
        sender?.kf_setBackgroundImageWithURL(NSURL(string: url)!, forState: .Normal, placeholderImage: R.image.avatar)
        sender?.layer.borderWidth = 2

        switch sender {
        case .Some(button1):
            sender?.layer.borderColor = UIColor.gaikeRedColor().CGColor
            titleLabel1.text = nickname
            score1 = score
            if annotation1 == nil {
                annotation1 = MAPointAnnotation()
                mapView.addAnnotation(annotation1!)
            }
            if let first = score.data.first {
                annotation1?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
            }
        case .Some(button2):
            sender?.layer.borderColor = UIColor(rgbValue: 0x13931B).CGColor
            titleLabel2.text = nickname
            score2 = score
            if annotation2 == nil {
                annotation2 = MAPointAnnotation()
                mapView.addAnnotation(annotation2!)
            }
            if let first = score.data.first {
                annotation2?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
            }
        case .Some(button3):
            sender?.layer.borderColor = UIColor(rgbValue: 0x007AFF).CGColor
            titleLabel3.text = nickname
            score3 = score
            if annotation3 == nil {
                annotation3 = MAPointAnnotation()
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

extension TrackDetailViewController: MAMapViewDelegate {
    func mapView(mapView: MAMapView!, didSingleTappedAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
        print("[\(coordinate.latitude), \(coordinate.longitude), 0]")
    }

    func mapView(mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        delay(0.1) { // avoid crash when double tap mapview
            if mapView.zoomLevel < 16 {
                mapView.zoomLevel = 16
            }

            if mapView.zoomLevel > 17 {
                mapView.zoomLevel = 17
            }
        }
    }

    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        guard let circle = overlay as? MACircle else {
            return nil
        }

        let circleView = MACircleView(circle: circle)
        circleView.strokeColor = UIColor.blackColor()
        circleView.lineWidth = 1
        circleView.fillColor = UIColor.yellowColor()

        if circle.coordinate.longitude == 121.121573354806 {
            circleView.fillColor = UIColor.redColor()
        }
        return circleView
    }

    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        guard let annotation = annotation as? MAPointAnnotation else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotation") as? MAPinAnnotationView
        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            if annotation == annotation1 {
                annotationView?.image = R.image.red_helmet
            }
            if annotation == annotation2 {
                annotationView?.image = R.image.green_helmet
            }
            if annotation == annotation3 {
                annotationView?.image = R.image.blue_helmet
            }
            annotationView?.layer.shadowOffset = CGSize(width: 1, height: 2)
            annotationView?.layer.shadowRadius = 1
            annotationView?.layer.shadowOpacity = 1
        }
        return annotationView
    }
}
