//
//  CLLocationCoordinate2D.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/8.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

extension CLLocationCoordinate2D {
    func latitudeString() -> String {
        var latSeconds = Int(latitude * 3600)
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        return String(format:"%d°%d'%d\"%@",
            abs(latDegrees),
            latMinutes,
            latSeconds,
            {return latDegrees >= 0 ? "N" : "S"}() )
    }
    
    func longitudeString() -> String {
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        return String(format:"%d°%d'%d\"%@",
            abs(longDegrees),
            longMinutes,
            longSeconds,
            {return longDegrees >= 0 ? "E" : "W"}() )
    }
}