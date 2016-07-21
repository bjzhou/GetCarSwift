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
    dynamic var id = 0
    dynamic var name = ""
    dynamic var mapCenter: RmLocation?
    dynamic var mapZoom: CGFloat = 0.0
    dynamic var address = ""
    dynamic var mapDegree: CGFloat = 0.0
    dynamic var introduce = ""
    dynamic var star = "star3"
    dynamic var sightView = ""
    dynamic var mapImage = ""
    dynamic var isDeveloped = false
    dynamic var startLoc: RmLocation?
    dynamic var stopLoc: RmLocation?
    dynamic var leaveLoc: RmLocation?
    var passLocs = List<RmLocation>()
    dynamic var cycle = true

    override class func primaryKey() -> String? {
        return "id"
    }

    func getSightViewImage(_ closure: (UIImage) -> ()) {
        UIImage.asyncInit(self.sightView) { img in
            if let img = img {
                closure(img)
            } else {
                UIImage.asyncInit(self.name) { img in
                    if let img = img {
                        closure(img)
                        self.realm?.writeOptional {
                            self.sightView = self.name
                        }
                    }
                }
            }
        }
    }

    func getMapImageImage(_ closure: (UIImage) -> ()) {
        UIImage.asyncInit(self.mapImage) { img in
            if let img = img {
                closure(img)
            } else {
                UIImage.asyncInit(self.name + " 赛道") { img in
                    if let img = img {
                        closure(img)
                        self.realm?.writeOptional {
                            self.mapImage = self.name + " 赛道"
                        }
                    }
                }
            }
        }
    }
}

class RmLocation: Object {
    dynamic var latitude = 0.0
    dynamic var longitude = 0.0
    dynamic var altitude = 0.0
}
