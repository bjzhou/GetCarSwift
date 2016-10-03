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

class TrackDetailViewController: UIViewController, CAAnimationDelegate {

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
            button?.layer.masksToBounds = true
            button?.layer.cornerRadius = 23.5
        }

        self.navigationItem.rightBarButtonItem?.image = R.image.nav_item_comment()?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.setBackgroundVerticalPositionAdjustment(3, for: .default)

        mapView.showsCompass = false
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = false
        mapView.isShowsLabels = false
        mapView.isSkyModelEnabled = false
        //mapView.mapType = .Satellite
        mapView.delegate = self
        if let raceTrack = trackDetailViewModel.raceTrack, let mapCenter = raceTrack.mapCenter {
            mapView.zoomLevel = raceTrack.mapZoom
            mapView.setCenter(CLLocationCoordinate2DMake(mapCenter.latitude, mapCenter.longitude), animated: false)

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

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(TrackDetailViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TrackDetailViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        timerDisposable?.dispose()
    }

    func keyboardWillShow(_ notification: UIKit.Notification) {
        guard let userInfo = (notification as NSNotification).userInfo, let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }

        self.postViewPos.constant = keyboardSize.height
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillHide(_ notification: UIKit.Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.postViewPos.constant = 0
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    func initTrackData() {
        self.title = trackDetailViewModel.raceTrack?.name ?? ""
        trackDetailViewModel.getComments().subscribe(onNext: { comments in
            for comment in comments {
                self.danmuEffect?.send(comment.content, delay: 1, highlight: comment.uid == Mine.sharedInstance.id)
            }
        }).addDisposableTo(disposeBag)
    }

    @IBAction func didStart(_ sender: UIButton) {
        let stopTime = max(max(score1?.score ?? 0, score2?.score ?? 0), score3?.score ?? 0)
        if stopTime == 0 { return }

        sender.isSelected = !sender.isSelected
        if self.timerOffset == 0 {
            timerDisposable?.dispose()
            mapView.isZoomEnabled = false
            mapView.isRotateEnabled = false
            mapView.isRotateCameraEnabled = false
            timerDisposable = Observable<Int>.timer(0, period: 0.01, scheduler: MainScheduler.instance).subscribe(onNext: { _ in
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

                if t >= stopTime {
                    self.timerDisposable?.dispose()
                    sender.isSelected = !sender.isSelected
                    self.timerOffset = 0
                    self.mapView.isZoomEnabled = true
                    self.mapView.isRotateEnabled = true
                    self.mapView.isRotateCameraEnabled = true
                }
            })
            startAnim(annotation1, score: score1)
            startAnim(annotation2, score: score2)
            startAnim(annotation3, score: score3)
        } else {
            if !sender.isSelected {
                // pause
                mapView.view(for: annotation1)?.layer.pauseAnimation()
                mapView.view(for: annotation2)?.layer.pauseAnimation()
                mapView.view(for: annotation3)?.layer.pauseAnimation()
            } else {
                // resume
                mapView.view(for: annotation1)?.layer.resumeAnimation()
                mapView.view(for: annotation2)?.layer.resumeAnimation()
                mapView.view(for: annotation3)?.layer.resumeAnimation()
            }
        }
    }

    func startAnim(_ annotation: MAPointAnnotation?, score: RmScore?) {
        guard let score = score, let annotation = annotation else {
            return
        }

        annotation.coordinate = CLLocationCoordinate2DMake(score.data.first?.lat ?? 0, score.data.first?.long ?? 0)
        let view = mapView.view(for: annotation)
        let points: [CGPoint] = score.data.map { data in
            let loc = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
            return self.mapView.convert(loc, toPointTo: self.mapView)
        }
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.duration = score.score
        anim.keyTimes = score.data.map { ($0.t / score.score) as NSNumber }
        anim.values = points.map { NSValue(cgPoint: CGPoint(x: $0.x - points[0].x, y: $0.y - points[0].y)) }
        anim.calculationMode = kCAAnimationLinear
        anim.isRemovedOnCompletion = false
        anim.fillMode = kCAFillModeForwards
        anim.isAdditive = true
        anim.delegate = self

        view?.layer.add(anim, forKey: "race")
    }

    func stopAnim() {
        mapView.view(for: annotation1)?.layer.resumeAnimation()
        mapView.view(for: annotation2)?.layer.resumeAnimation()
        mapView.view(for: annotation3)?.layer.resumeAnimation()
        mapView.view(for: annotation1)?.layer.removeAllAnimations()
        mapView.view(for: annotation2)?.layer.removeAllAnimations()
        mapView.view(for: annotation3)?.layer.removeAllAnimations()
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

    @IBAction func didAddPlayer(_ sender: UIButton) {
        let addViewController = AddPlayerTableViewController()
        addViewController.delegate = self
        addViewController.sender = sender
        addViewController.sid = trackDetailViewModel.sid
        let popupViewController = PopupViewController(rootViewController: addViewController)
        self.present(popupViewController, animated: false, completion: nil)
    }

    @IBAction func didPostComment(_ sender: UIButton) {
        if commentTextField.text!.trim() == "" {
            Toast.makeToast(message: "评论不能为空")
            return
        }
        trackDetailViewModel?.postComment(commentTextField.text!).subscribe(onNext: {
            self.danmuEffect?.send(self.commentTextField.text!, highlight: true, highPriority: true)
            self.commentTextField.text = ""
            }).addDisposableTo(disposeBag)
        self.view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.trackDetailViewController.track_comment.identifier {
            if let destVc = segue.destination as? CommentsViewController {
                destVc.trackDetailViewModel = trackDetailViewModel
            }
        }
    }

}

extension TrackDetailViewController: AddPlayerDelegate {
    func didPlayerAdded(_ score: AnyObject, sender: UIButton?) {
        guard let score = score as? RmScore else {
            return
        }
        var url = score.headUrl
        var nickname = score.nickname
        if url == "" {
            url = Mine.sharedInstance.avatarUrl
        }
        if nickname == "" {
            nickname = Mine.sharedInstance.nickname
        }
        sender?.kf.setBackgroundImage(with: URL(string: url)!, for: .normal, placeholder: R.image.avatar())
        sender?.layer.borderWidth = 2

        timerDisposable?.dispose()
        startButton.isSelected = false
        timerOffset = 0
        stopAnim()
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.isRotateCameraEnabled = true

        switch sender {
        case .some(button1):
            sender?.layer.borderColor = UIColor.gaikeRedColor().cgColor
            titleLabel1.text = nickname
            score1 = score
            if annotation1 == nil {
                annotation1 = MAPointAnnotation()
                if let first = score.data.first {
                    annotation1?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
                mapView.addAnnotation(annotation1!)
            } else {
                if let first = score.data.first {
                    annotation1?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
            }
        case .some(button2):
            sender?.layer.borderColor = UIColor(rgbValue: 0x13931B).cgColor
            titleLabel2.text = nickname
            score2 = score
            if annotation2 == nil {
                annotation2 = MAPointAnnotation()
                if let first = score.data.first {
                    annotation2?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
                mapView.addAnnotation(annotation2!)
            } else {
                if let first = score.data.first {
                    annotation2?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
            }
        case .some(button3):
            sender?.layer.borderColor = UIColor(rgbValue: 0x007AFF).cgColor
            titleLabel3.text = nickname
            score3 = score
            if annotation3 == nil {
                annotation3 = MAPointAnnotation()
                if let first = score.data.first {
                    annotation3?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
                mapView.addAnnotation(annotation3!)
            } else {
                if let first = score.data.first {
                    annotation3?.coordinate = CLLocationCoordinate2D(latitude: first.lat, longitude: first.long)
                }
            }
        default:
            break
        }
    }
}

extension TrackDetailViewController: MAMapViewDelegate {
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
        print("[\(coordinate.latitude), \(coordinate.longitude), 0]")
    }

    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        delay(0.1) { // avoid crash when double tap mapview
            if mapView.zoomLevel < 16 {
                mapView.zoomLevel = 16
            }

            if mapView.zoomLevel > 17 {
                mapView.zoomLevel = 17
            }
        }
    }

    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        guard let circle = overlay as? MACircle else {
            return nil
        }

        let circleView = MACircleRenderer(circle: circle)
        circleView?.strokeColor = UIColor.black
        circleView?.lineWidth = 1
        circleView?.fillColor = UIColor.yellow

        if circle.coordinate.longitude == 121.121573354806 {
            circleView?.fillColor = UIColor.red
        }
        return circleView
    }

    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        guard let annotation = annotation as? MAPointAnnotation else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        if annotationView == nil {
            annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            if annotation == annotation1 {
                annotationView?.image = R.image.red_helmet()
            }
            if annotation == annotation2 {
                annotationView?.image = R.image.green_helmet()
            }
            if annotation == annotation3 {
                annotationView?.image = R.image.blue_helmet()
            }
            annotationView?.layer.shadowOffset = CGSize(width: 1, height: 2)
            annotationView?.layer.shadowRadius = 1
            annotationView?.layer.shadowOpacity = 1
        }
        return annotationView!
    }
}
