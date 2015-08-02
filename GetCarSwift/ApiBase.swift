//
//  ApiBase.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/2.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

let memoryCapacity = 20 * 1024 * 1024
let diskCapacity = 100 * 1024 * 1024
let cache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")

func initConfiguration() -> NSURLSessionConfiguration {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let defaultHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
    configuration.HTTPAdditionalHeaders = defaultHeaders
    configuration.requestCachePolicy = .UseProtocolCachePolicy
    configuration.URLCache = cache
    return configuration
}

let apiManager = Manager(configuration: initConfiguration())