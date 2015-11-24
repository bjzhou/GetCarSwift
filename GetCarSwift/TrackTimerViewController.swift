//
//  TrackTimerViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class TrackTimerViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var scoreBest: UILabel!
    @IBOutlet weak var scoreLastest1: UILabel!
    @IBOutlet weak var scoreLastest2: UILabel!
    @IBOutlet weak var scoreLastest3: UILabel!

    var raceTrack = RmRaceTrack()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
