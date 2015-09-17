//
//  Globals.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import Foundation
import Haneke
import SwiftyJSON
import CoreMotion

let VERSION_SHORT = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
let VERSION = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String

let IMAGE_ARROW = "arrow"
let IMAGE_DABAOWEI = "gz_baowei"
let IMAGE_HOURAO = "gz_hourao"
let IMAGE_LUNGU = "gz_lunkuo"
let IMAGE_RED_CAR = "gz_keluzi_red"
let IMAGE_YELLOW_CAR = "gz_keluzi_yellow"
let IMAGE_BLUE_CAR = "gz_keluzi_blue"
let IMAGE_GRAY_CAR = "gz_keluzi_gray"
let IMAGE_AVATAR = "avatar"
let IMAGE_MYCAR_HISTORY = "mycar_history"
let IMAGE_MYCAR_XINGNENG = "mycar_xingneng"
let IMAGE_MYCAR_XINPIN = "mycar_xinpin"
let IMAGE_QRCODE = "qrcode"
let IAMGE_ACCESSORY = "accessory"
let IAMGE_ACCESSORY_SELECTED = "accessory_selected"
let IMAGE_CAR_INFO_AREA = "car_info_area"
let IMAGE_CAR_INFO_AREA_PRESSED = "car_info_area_pressed"

let AMAP_KEY = "751ca4d9d8c3a9bd8ef2e2b64a8e7cb4"
let BUGLY_APPID = "900007462"


let imageCache = Shared.imageCache

/*
获得地图界面定位图标名
sex: 性别，0男/1女
color:颜色类型，101-110
icon:图标类型，201-206
*/
func getCarIconName(sex: Int, color: Int, icon: Int) -> String {
    return getSexString(sex) + "  " + getColorByTag(color) + getIconString(icon) + " 选中"
}

func getNoSexCarIconName(color: Int, icon: Int) -> String {
    return getColorByTag(color) + getIconString(icon)
}

/*
获得颜色图标名
sex: 性别，0男/1女
color:颜色类型，101-110
*/
func getColorIconName(sex: Int, color: Int) -> String {
    return getSexString(sex) + "  " + getColorByTag(color) + " 选中"
}

func getColorByTag(tag: Int) -> String {
    switch tag {
    case 0:
        // default value
        return "红"
    case 101:
        return "红"
    case 102:
        return "蓝"
    case 103:
        return "白"
    case 104:
        return "银"
    case 105:
        return "灰"
    case 106:
        return "黑"
    case 107:
        return "黄"
    case 108:
        return "绿"
    case 109:
        return "紫"
    default:
        return "其他"
    }
}

func getSexString(sex: Int) -> String {
    return sex == 1 ? "男" : "女"
}

func getIconString(icon: Int) -> String {
    return icon == 0 ? "1" : String(icon - 200)
}

func getSmallHomepageBg(index: Int) -> String {
    return "homepage_bg" + String(index) + "_small"
}

func getHomepageBg(index: Int) -> String {
    return "homepage_bg" + String(index)
}

infix operator ~> {}
let queue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)

func ~>(bgThread: () -> (), mainThread: () -> ()) {
    dispatch_async(queue) {
        bgThread()
        dispatch_async(dispatch_get_main_queue(), mainThread)
    }
}

func ~><T>(bgThread: () -> T, mainThread: (result: T) -> ()) {
    dispatch_async(queue) {
        let result = bgThread()
        dispatch_async(dispatch_get_main_queue()) {
            mainThread(result: result)
        }
    }
}

func async(bgThread: () -> Void) {
    dispatch_async(queue, bgThread)
}

func updateLogin(json: SwiftyJSON.JSON) {
    let defaults = NSUserDefaults.standardUserDefaults()

    if let car = json["car"].string {
        defaults.setValue(car, forKey: "car")
    }
    if let phone = json["phone"].string {
        defaults.setValue(phone, forKey: "phone")
    }
    if let id = json["id"].string {
        defaults.setValue(id, forKey: "id")
    }

    if let token = json["token"].string {
        DataKeeper.sharedInstance.token = token
    }
    if let nickname = json["nickname"].string {
        DataKeeper.sharedInstance.nickname = nickname
    }
    if let sex = json["sex"].string {
        DataKeeper.sharedInstance.sex = sex.intValue
    }
    if let avatarUrl = json["img"].string {
        var mutableUrl = avatarUrl
        if !avatarUrl.hasPrefix("http://") {
            mutableUrl = "http://pic.gaikit.com/user/head/" + avatarUrl
        }
        DataKeeper.sharedInstance.avatarUrl = mutableUrl
    }
}

func logout() {
    DataKeeper.sharedInstance.token = nil
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let firstController = storyboard.instantiateViewControllerWithIdentifier("login") 
    let window = UIApplication.sharedApplication().keyWindow
    window?.rootViewController = firstController

    firstController.view.makeToast(message: "登录信息已过期，请重新登录")
}

public class DataKeeper {
    static let sharedInstance = DataKeeper()

    private var delegates: [DataKeeperDelegate] = []

    public var token: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("token")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "token")
        }
    }

    public var nickname: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("nickname")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "nickname")
        }
    }

    public var sex: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("sex")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "sex")
            for delegate in delegates {
                delegate.didSexUpdated?(newValue)
            }
        }
    }

    public var avatarUrl: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("avatar")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "avatar")
        }
    }

    public var carHeadId: Int {
        get {
            let tmp = NSUserDefaults.standardUserDefaults().integerForKey("car_head_id")
            return  tmp == 0 ? 201 : tmp
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car_head_id")
            for delegate in delegates {
                delegate.didCarHeadIdUpdated?(newValue)
            }
        }
    }

    public var carHeadBg: Int {
        get {
            let tmp = NSUserDefaults.standardUserDefaults().integerForKey("car_head_bg")
            return tmp == 0 ? 101 : tmp
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car_head_bg")
            for delegate in delegates {
                delegate.didCarHeadBgUpdated?(newValue)
            }
        }
    }

    public var location: CLLocation? {
        didSet {
            if let location = location where location.speed >= 0 {
                for delegate in delegates {
                    delegate.didLocationUpdated?(location)
                }
            }
        }
    }

    public var acceleration: CMAcceleration? {
        didSet {
            if let acceleration = acceleration {
                for delegate in delegates {
                    delegate.didAccelerationUpdated?(acceleration)
                }
            }
        }
    }

    public var altitude: CMAltitudeData? {
        didSet {
            if let altitude = altitude {
                for delegate in delegates {
                    delegate.didAltitudeUpdated?(altitude)
                }
            }
        }
    }

    public func addDelegate(delegate: DataKeeperDelegate) {
        delegates.append(delegate)
    }
}

@objc public protocol DataKeeperDelegate {
    optional func didLocationUpdated(location: CLLocation)
    optional func didAccelerationUpdated(acceleration: CMAcceleration)
    optional func didAltitudeUpdated(altitude: CMAltitudeData)
    optional func didCarHeadBgUpdated(carHeadBg: Int)
    optional func didCarHeadIdUpdated(carHeadId: Int)
    optional func didSexUpdated(sex: Int)
}
