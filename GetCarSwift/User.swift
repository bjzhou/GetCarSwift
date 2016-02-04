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
    var phone = ""
    var id = ""
    var car = ""
    var nickname = ""
    var sex: Int? = 1
    var img = ""
    var token = ""

    static var rxMine: Variable<Mine> = Variable(Mine.sharedInstance)

    init(json: JSON) {
        phone = json["phone"].stringValue
        id = json["id"].stringValue
        car = json["car"].stringValue
        nickname = json["nickname"].stringValue
        sex = json["sex"].intValue
        img = json["img"].stringValue

        token = json["token"].stringValue

        if img == "" {
            img = json["head_url"].stringValue
        }

        if img != "" && !img.hasPrefix("http://") {
            img = "http://pic.gaikit.com/user/head/" + img
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

    static func getIMToken() -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/getIMToken")
    }

    /* follow: false: 我关注的人， true: 关注我的人 */
    static func getFriend(follow: Bool) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/get_friend", body: ["get_followed": follow])
    }

    static func addFriend(uid: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/add_friend", body: ["id": uid])
    }

    static func searchUser(nickname: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/search_user", body: ["nickname": nickname])
    }

    static func removeFriend(uid: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/remove_friend", body: ["id": uid])
    }

    static func getUserInfo(uid: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/get_user_info", body: ["id": uid])
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
        imageView.updateAvatar(Mine.sharedInstance.id, url: Mine.sharedInstance.avatarUrl, tappable: false, inVC: nil)
    }

    mutating func updateLogin(user: User) {
        if car != "" {
            self.car = car
        }
        if phone != "" {
            self.phone = phone
        }
        if id != "" {
            self.id = id
        }

        if token != "" {
            self.token = token
        }
        if nickname != "" {
            self.nickname = nickname
        }
        if let sex = user.sex {
            self.sex = sex
        }
        if avatarUrl != "" {
            self.avatarUrl = avatarUrl
        }
    }

    mutating func logout(expired expired: Bool = true) {
        RCIM.sharedRCIM().disconnect(false)
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
