//
//  CarApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/15.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class CarApi: GaikeApi {
    static let sharedInstance = CarApi()
    var path = "car/"

    func info(completion: GKResult -> Void) {
        apiCache.fetch(fetcher: GKFetcher(api: self, method: "info")).onSuccess(completion)
    }
}