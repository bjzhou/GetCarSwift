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

        trackView.image = getSightView()
        trackTitleLabel.text = raceTrack.name
        trackDetailLabel.text = raceTrack.introduce
        trackMapImageView.image = getmapImage()
    }

    func getSightView() -> UIImage {
        if let image = UIImage(named: raceTrack.sightView) {
            return image
        } else if let image = UIImage(named: raceTrack.name) {
            try! realm.write {
                self.raceTrack.sightView = self.raceTrack.name
            }
            return image
        }
        return UIImage()
    }

    func getmapImage() -> UIImage {
        if let image = UIImage(named: raceTrack.mapImage) {
            return image
        } else if let image = UIImage(named: raceTrack.name + " 赛道") {
            try! realm.write {
                self.raceTrack.mapImage = self.raceTrack.name + " 赛道"
            }
            return image
        }
        return UIImage()
    }

}
