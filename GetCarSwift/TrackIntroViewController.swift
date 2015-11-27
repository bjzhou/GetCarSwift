//
//  TrackIntroViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/27.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackIntroViewController: UIViewController {

    @IBOutlet weak var trackView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackDetailLabel: UILabel!
    @IBOutlet weak var trackMapImageView: UIImageView!

    var raceTrack = RmRaceTrack()

    override func viewDidLoad() {
        super.viewDidLoad()

        trackView.image = UIImage(named: raceTrack.sightView)
        trackTitleLabel.text = raceTrack.name
        trackDetailLabel.text = raceTrack.introduce
        trackMapImageView.image = UIImage(named: raceTrack.mapImage)
    }

}
