//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher
import SwiftyJSON

struct User: JSONable {
    var phone: String?
    var id: String?
    var car: String?
    var nickname: String?
    var sex: Int?
    var img: String?
    var token: String?

    static var rxMine: Variable<Mine> = Variable(Mine.sharedInstance)

    init(json: JSON) {
        phone = json["phone"].string
        id = json["id"].string
        car = json["car"].string
        nickname = json["nickname"].string
        sex = json["sex"].intValue
        img = json["img"].string
        token = json["token"].string

        if let wrappedImg = img where !wrappedImg.hasPrefix("http://") {
            img = "http://pic.gaikit.com/user/head/" + wrappedImg
        }
    }

    static func getCodeMsg(phone: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/getCodeMsg", body: ["phone":phone])
    }

    static func login(phone phone: String, code: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/login", body: ["phone":phone, "code":code])
    }

    static func updateInfo(nickname nickname: String? = nil, sex: Int? = nil, color: String? = nil, icon: String? = nil) -> Observable<GKResult<User>> {
        var params: [String:AnyObject] = [:]
        let datas: [String:NSData] = [:]
        if let a = nickname {
            params["nickname"] = a
        }
        if let a = sex {
            params["sex"] = a
        }
        if let a = color {
            params["color"] = a
        }
        if let a = icon {
            params["icon"] = a
        }
        return GaikeService.sharedInstance.upload("user/updateInfo", parameters: params, datas: datas)
    }

    static func uploadHeader(image: UIImage) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.upload("upload/uploadHeader", datas: ["pictures":UIImagePNGRepresentation(image)!])
    }
}

struct Mine {
    static var sharedInstance = Mine()
    var token: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("token")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "token")
            User.rxMine.value = self
        }
    }

    var id: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("id") ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "id")
            User.rxMine.value = self
        }
    }

    var phone: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("phone") ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "phone")
            User.rxMine.value = self
        }
    }

    var car: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("car")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car")
            User.rxMine.value = self
        }
    }

    var nickname: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("nickname") ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "nickname")
            User.rxMine.value = self
        }
    }

    var sex: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("sex")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "sex")
            User.rxMine.value = self
        }
    }

    var avatarUrl: String {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("avatar") ?? ""
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "avatar")
            User.rxMine.value = self
        }
    }

    var carHeadId: Int {
        get {
            let tmp = NSUserDefaults.standardUserDefaults().integerForKey("car_head_id")
            return  tmp == 0 ? 201 : tmp
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car_head_id")
            User.rxMine.value = self
        }
    }

    var carHeadBg: Int {
        get {
            let tmp = NSUserDefaults.standardUserDefaults().integerForKey("car_head_bg")
            return tmp == 0 ? 101 : tmp
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car_head_bg")
            User.rxMine.value = self
        }
    }

    func setAvatarImage(imageView: UIImageView) {
        imageView.updateAvatar(Mine.sharedInstance.id, url: Mine.sharedInstance.avatarUrl, nickname: Mine.sharedInstance.nickname, sex: Mine.sharedInstance.sex, tappable: false, inVC: nil)
    }

    mutating func updateLogin(user: User) {
        if let car = user.car where car != "" {
            self.car = car
        }
        if let phone = user.phone where phone != "" {
            self.phone = phone
        }
        if let id = user.id where id != "" {
            self.id = id
        }

        if let token = user.token where token != "" {
            self.token = token
        }
        if let nickname = user.nickname where nickname != "" {
            self.nickname = nickname
        }
        if let sex = user.sex {
            self.sex = sex
        }
        if let avatarUrl = user.img where avatarUrl != "" {
            self.avatarUrl = avatarUrl
        }
    }

    mutating func logout(expired expired: Bool = true) {
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        KingfisherManager.sharedManager.cache.clearDiskCache()
        main {
            gRealm?.writeOptional {
                if let objects = gRealm?.objects(RmScore) {
                    gRealm?.delete(objects)
                }
            }
            let firstController = R.storyboard.login.login!
            let window = UIApplication.sharedApplication().keyWindow
            window?.rootViewController = firstController

            if expired {
                Toast.makeToast(message: "登录信息已过期，请重新登录")
            }
        }
    }
}
