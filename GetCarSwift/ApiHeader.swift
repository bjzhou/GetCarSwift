//
//  ApiHeader.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

public class ApiHeader {
    static let sharedInstance = ApiHeader()
    
    public var delegate: LocationUpdateDelegate?

    public var token: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
        }
    }

    public var location: CLLocation? {
        didSet {
            if let location = location {
                delegate?.didLocationUpdated(location)
            }
        }
    }
    
    init() {
        token = NSUserDefaults.standardUserDefaults().stringForKey("token")
    }
}

public protocol LocationUpdateDelegate {
    func didLocationUpdated(location: CLLocation)
}