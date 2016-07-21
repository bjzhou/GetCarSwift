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
import RxSwift

class RmScore: Object, JSONable {
    dynamic var id = UUID().uuidString
    dynamic var url = ""
    dynamic var uid = ""
    dynamic var nickname = ""
    dynamic var mapType = 0
    dynamic var headUrl = ""
    dynamic var createdAt = Date().timeIntervalSince1970
    dynamic var score = 0.0
    var data = List<RmScoreData>()

    convenience required init(json: JSON) {
        self.init()

        id = json["id"].stringValue
        url = json["url"].stringValue
        uid = json["uid"].stringValue
        nickname = json["nickname"].stringValue
        score = json["duration"].doubleValue
        mapType = json["map_type"].intValue
        headUrl = json["head_url"].stringValue
    }

    override class func primaryKey() -> String? { return "id" }

    func archive() -> Data {
        let dic = data.map { el in
            return ["t": el.t, "v": el.v, "a": el.a, "s": el.s, "lat": el.lat, "long": el.long, "alt": el.alt]
        }
        return NSKeyedArchiver.archivedData(withRootObject: dic)
    }

    func unarchive(_ succeed: (RmScore) -> ()) {
        if self.data.count != 0 {
            succeed(self)
            return
        }
        _ = GaikeService.sharedInstance.request(url).subscribeNext { data in
            guard let recordArray = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [[String: Double]] else {
                return
            }

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
            if let realm = self.realm {
                realm.writeOptional {
                    self.data.append(objectsIn: scoreDataArray)
                }
            } else {
                self.data.append(objectsIn: scoreDataArray)
            }
            succeed(self)
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

struct Records: JSONable {
    var newestRes: [RmScore] = []
    var bestRes: [RmScore] = []
    var top: [RmScore] = []

    init(json: JSON) {
        newestRes = json["newestRes"].arrayValue.map { RmScore(json: $0) }
        bestRes = json["bestRes"].arrayValue.map { RmScore(json: $0) }
        top = json["top"].arrayValue.map { RmScore(json: $0) }
    }

    static func getRecord(_ mapType: Int, count: Int) -> Observable<GKResult<Records>> {
        return GaikeService.sharedInstance.api("user/getRecord", body: ["map_type": mapType, "count": count])
    }

    static func getTimeRecord(_ mapType: Int, time: String, count: Int) -> Observable<GKResult<Records>> {
        return GaikeService.sharedInstance.api("user/getTimeRecord", body: ["map_type": mapType, "time": time, "count": count])
    }

    static func getFollowRecord(_ mapType: Int, count: Int) -> Observable<GKResult<Records>> {
        return GaikeService.sharedInstance.api("user/getFollowRecord", body: ["map_type": mapType, "count": count])
    }

    static func uploadRecord(_ mapType: Int, duration: Double, recordData: NSData) -> Observable<GKResult<RmScore>> {
        return GaikeService.sharedInstance.upload("upload/uploadRecord", parameters: ["duration": duration, "map_type": mapType], datas: ["record": recordData as Data])
    }
}
