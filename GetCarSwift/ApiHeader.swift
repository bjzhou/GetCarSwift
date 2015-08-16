//
//  ApiHeader.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import Foundation

public class ApiHeader {
    static let sharedInstance = ApiHeader()

    public var token: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
        }
    }

    public var location: CLLocation?
    
    init() {
        token = NSUserDefaults.standardUserDefaults().stringForKey("token")
    }
}