//
//  RaceTrack.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/12.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RealmSwift

class RmRaceTrack: Object {
    dynamic var id = ""
    dynamic var name = ""
    dynamic var mapCenter: RmLocation?
    dynamic var mapZoom = 0.0
    dynamic var address = ""
    dynamic var sightView = ""
    dynamic var isDeveloped = false
    dynamic var startLoc: RmLocation?
    dynamic var stopLoc: RmLocation?
    dynamic var leaveLoc: RmLocation?
    var passLocs = List<RmLocation>()
    dynamic var cycle = true

    override class func primaryKey() -> String? {
        return "id"
    }
}

class RmLocation: Object {
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
}
