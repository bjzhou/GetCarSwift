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
    var record = List<RmScoreData>()

    func asData() -> NSData {
        let dic = record.map { el in
            return ["t": el.t, "v": el.v, "a": el.a, "s": el.s, "lat": el.lat, "long": el.long, "alt": el.alt]
        }
        return NSKeyedArchiver.archivedDataWithRootObject(dic)
    }

    func fillRecord(data: NSData) {
        if let recordArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: Double]] {
            let scoreDataArray: [RmScoreData] = recordArray.map { dic in
                let scoreData = RmScoreData()
                scoreData.t = dic["t"] ?? 0
                scoreData.v = dic["v"] ?? 0
                scoreData.a = dic["a"] ?? 0
                scoreData.s = dic["s"] ?? 0
                scoreData.lat = dic["lat"] ?? 0
                scoreData.long = dic["long"] ?? 0
                scoreData.alt = dic["alt"] ?? 0
                return scoreData
            }
            record.appendContentsOf(scoreDataArray)
        }
    }
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
