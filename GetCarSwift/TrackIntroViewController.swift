//
//  TrackIntroViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/27.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift

class TrackIntroViewController: UIViewController {

    let realm = try! Realm()

    @IBOutlet weak var trackView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackDetailLabel: UILabel!
    @IBOutlet weak var trackMapImageView: UIImageView!

    var raceTrack = RmRaceTrack()

    override func viewDidLoad() {
        super.viewDidLoad()

        raceTrack.getSightViewImage { img in
            self.trackView.image = img
        }
        trackTitleLabel.text = raceTrack.name
        trackDetailLabel.text = raceTrack.introduce
        raceTrack.getMapImageImage { img in
            self.trackMapImageView.image = img
        }
    }

}
