//
//  CarApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/15.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

class CarApi: GaikeService {
    static let sharedInstance = CarApi()

    override func path() -> String {
        return "car/"
    }

    func info(completion: GKResult -> ()) {
        apiCache.fetch(fetcher: GKFetcher<GKResult>(api: self, method: "info")).onSuccess(completion)
    }
}