//
//  RaceTrack.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/12.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RealmSwift

class RaceTrack: Object {
    dynamic var name = ""
    dynamic var mapCenterLat = 0.0
    dynamic var mapCenterLong = 0.0
    dynamic var mapZoom = 0.0
    dynamic var startLat = 0.0
    dynamic var startLong = 0.0
    dynamic var startAlt = 0.0
    dynamic var stopLat = 0.0
    dynamic var stopLong = 0.0
    dynamic var stopAlt = 0.0
    dynamic var cycle = false

    override class func primaryKey() -> String? {
        return "name"
    }
}
