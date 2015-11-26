//
//  RmScore.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/11.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class RmScore: Object {
    dynamic var type = ""
    dynamic var createdAt = NSDate().timeIntervalSince1970
    dynamic var score = 0.0
    dynamic var name = ""
    var data = List<RmScoreData>()
}

class RmScoreData: Object {
    dynamic var t = 0.0
    dynamic var v = 0.0
    dynamic var a = 0.0
    dynamic var s = 0.0
    dynamic var lat = 0.0
    dynamic var long = 0.0
    dynamic var alt = 0.0
}
