//
//  AccountApi.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/5.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import Haneke
import SwiftyJSON

struct User: JSONable {
    var phone: String?
    var id: String?
    var car: String?
    var nickname: String?
    var sex: Int?
    var img: String?
    var token: String?

    static var rx_me: Variable<Me> = Variable(Me.sharedInstance)

    init(json: SwiftyJSON.JSON) {
        phone = json["phone"].string
        id = json["id"].string
        car = json["car"].string
        nickname = json["nickname"].string
        sex = json["sex"].int
        img = json["img"].string
        token = json["token"].string

        if let wrappedImg = img {
            if !wrappedImg.hasPrefix("http://") {
                img = "http://pic.gaikit.com/user/head/" + wrappedImg
            }
        }
    }

    static func getCodeMsg(phone: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/getCodeMsg", body: ["phone":phone])
    }

    static func login(phone phone: String, code: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/login", body: ["phone":phone, "code":code])
    }

    static func updateInfo(nickname nickname: String, sex: Int, car: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/updateInfo", body: ["nickname":nickname, "sex":sex, "car":car])
    }

    static func updateInfo(color color: String, icon: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/updateInfo", body: ["car_head_bg":color, "car_head_id":icon])
    }

    static func uploadHeader(image: UIImage) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.upload("upload/uploadHeader", datas: ["pictures":UIImagePNGRepresentation(image)!])
    }
}

struct Me {
    static var sharedInstance = Me()
    var token: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("token")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "token")
            User.rx_me.value = self
        }
    }

    var id: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("id")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "id")
            User.rx_me.value = self
        }
    }

    var phone: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("phone")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "phone")
            User.rx_me.value = self
        }
    }

    var car: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("car")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car")
            User.rx_me.value = self
        }
    }

    var nickname: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("nickname")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "nickname")
            User.rx_me.value = self
        }
    }

    var sex: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("sex")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "sex")
            User.rx_me.value = self
        }
    }

    var avatarUrl: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("avatar")
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "avatar")
            User.rx_me.value = self
        }
    }

    var carHeadId: Int {
        get {
            let tmp = NSUserDefaults.standardUserDefaults().integerForKey("car_head_id")
            return  tmp == 0 ? 201 : tmp
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car_head_id")
            User.rx_me.value = self
        }
    }

    var carHeadBg: Int {
        get {
            let tmp = NSUserDefaults.standardUserDefaults().integerForKey("car_head_bg")
            return tmp == 0 ? 101 : tmp
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "car_head_bg")
            User.rx_me.value = self
        }
    }

    func fetchAvatar(result: UIImage -> ()) {
        if let avatarUrl = avatarUrl {
            Shared.imageCache.fetch(URL: NSURL(string: avatarUrl)!).onSuccess(result).onFailure { _ in
                    result(R.image.avatar!)
            }
        } else {
            result(R.image.avatar!)
        }
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

    mutating func logout() {
        self.token = nil
        MainScheduler.sharedInstance.schedule("", action: { _ in
            let firstController = R.storyboard.login.login!
            let window = UIApplication.sharedApplication().keyWindow
            window?.rootViewController = firstController

            firstController.view.makeToast(message: "登录信息已过期，请重新登录")

            return AnonymousDisposable {}
        })
    }
}