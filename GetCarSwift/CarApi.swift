//
//  CarApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/15.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class CarApi {
    static let PREFIX = "car/"

    class func info(completion: GKResult -> Void) {
        apiCache.fetch(fetcher: GKFetcher(urlString: PREFIX + "info", body: [:])).onSuccess(completion)
    }
}