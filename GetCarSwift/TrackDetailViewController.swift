//
//  TrackDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/3.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class TrackDetailViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackStar: UIImageView!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var loveLabel: UILabel!
    //@IBOutlet weak var mapImageView: UIImageView!

    @IBOutlet weak var trackDetailLabel: UILabel!
    @IBOutlet weak var index1Button: UIButton!
    @IBOutlet weak var index2Button: UIButton!
    @IBOutlet weak var index3Button: UIButton!

    var trackDetailViewModel: TrackDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        trackDetailViewModel.viewProxy = self
        initTrackData()
    }

    func initTrackData() {
        trackLabel.text = trackDetailViewModel.trackTitle
        trackDetailLabel.text = trackDetailViewModel.trackDetail
        trackStar.image = UIImage(named: trackDetailViewModel.trackStarString)
        //mapImageView.image = UIImage(named: trackDetailViewModel.trackMap)
        trackDetailViewModel.getComments()

        combineLatest(trackDetailViewModel.rx_loveButtonSelected, trackDetailViewModel.rx_lovedCount) { selected, lovedCount in
            return (selected, lovedCount)
            }.subscribeNext { selected, lovedCount in
                if selected {
                    self.loveLabel.text = "已想去"
                    return
                }
                if lovedCount <= 0 {
                    self.loveLabel.text = "想去"
                } else if lovedCount >= 1000 {
                    self.loveLabel.text = "想去\n(999+)"
                } else {
                    self.loveLabel.text = "想去\n(\(lovedCount))"
                }
        }.addDisposableTo(disposeBag)

        trackDetailViewModel.rx_loveButtonSelected.bindTo(loveButton.rx_selected).addDisposableTo(disposeBag)
    }

    override func viewDidLayoutSubviews() {
        initScrollView()
    }

    func initScrollView() {
        imageScrollView.delegate = self
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width*CGFloat(trackDetailViewModel.images.count), height: imageScrollView.frame.height)
        for i in 0..<trackDetailViewModel.images.count {
            let imageView = UIImageView(image: UIImage(named: trackDetailViewModel.images[i]))
            imageView.frame = CGRect(x: imageScrollView.frame.width*CGFloat(i), y: 0, width: self.view.frame.width, height: imageScrollView.frame.height)
            imageScrollView.addSubview(imageView)
        }
    }

    @IBAction func didIndexChanged(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
            self.imageScrollView.contentOffset.x = CGFloat(sender.tag) * self.imageScrollView.frame.width
        })
        updateIndexButton()
    }

    @IBAction func didLoveChanged(sender: UIButton) {
        trackDetailViewModel.didLoveChanged()
    }

    func updateIndexButton() {
        index1Button.selected = false
        index2Button.selected = false
        index3Button.selected = false

        switch (imageScrollView.contentOffset.x / imageScrollView.frame.width) {
        case 0:
            index1Button.selected = true
        case 1:
            index2Button.selected = true
        case 2:
            index3Button.selected = true
        default:
            break
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.track_comment {
            if let destVc = segue.destinationViewController as? CommentsViewController {
                destVc.trackDetailViewModel = trackDetailViewModel
            }
        }
    }

}

extension TrackDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateIndexButton()
    }
}
