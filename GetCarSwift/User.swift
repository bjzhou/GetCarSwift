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
    var friendStatus = 0 // 0: 好友 1: 已关注 2: 被关注

    static var rxMine: Variable<Mine> = Variable(Mine.sharedInstance)

    init(json: JSON) {
        phone = json["phone"].stringValue
        id = json["id"].stringValue
        car = json["car"].stringValue
        nickname = json["nickname"].stringValue
        sex = json["sex"].intValue
        img = json["img"].stringValue
        friendStatus = json["friend_status"].intValue

        token = json["token"].stringValue

        if img == "" {
            img = json["head_url"].stringValue
        }

        if img != "" && !img.hasPrefix("http://") {
            img = "http://pic.gaikit.com/user/head/" + img
        }
    }

    static func getCodeMsg(_ phone: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/getCodeMsg", body: ["phone":phone])
    }

    static func login(phone: String, code: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/login", body: ["phone":phone, "code":code])
    }

    static func updateInfo(nickname: String? = nil, sex: Int? = nil, color: String? = nil, icon: String? = nil) -> Observable<GKResult<User>> {
        var params: [String:AnyObject] = [:]
        let datas: [String:Data] = [:]
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

    static func uploadHeader(_ image: UIImage) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.upload("upload/uploadHeader", datas: ["pictures":UIImagePNGRepresentation(image)!])
    }

    static func getIMToken() -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/getIMToken")
    }

    static func getFriend() -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/get_friend")
    }

    static func addFriend(_ uid: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/add_friend", body: ["id": uid])
    }

    static func searchUser(_ nickname: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/search_user", body: ["param": nickname])
    }

    static func removeFriend(_ uid: String) -> Observable<GKResult<String>> {
        return GaikeService.sharedInstance.api("user/remove_friend", body: ["id": uid])
    }

    static func getUserInfo(_ uid: String) -> Observable<GKResult<User>> {
        return GaikeService.sharedInstance.api("user/get_user_info", body: ["id": uid])
    }
}

struct Mine {
    static var sharedInstance = Mine()
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
            User.rxMine.value = self
        }
    }

    var id: String {
        get {
            return UserDefaults.standard.string(forKey: "id") ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "id")
            User.rxMine.value = self
        }
    }

    var phone: String {
        get {
            return UserDefaults.standard.string(forKey: "phone") ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "phone")
            User.rxMine.value = self
        }
    }

    var car: String? {
        get {
            return UserDefaults.standard.string(forKey: "car")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "car")
            User.rxMine.value = self
        }
    }

    var nickname: String {
        get {
            return UserDefaults.standard.string(forKey: "nickname") ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "nickname")
            User.rxMine.value = self
        }
    }

    var sex: Int {
        get {
            return UserDefaults.standard.integer(forKey: "sex")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "sex")
            User.rxMine.value = self
        }
    }

    var avatarUrl: String {
        get {
            return UserDefaults.standard.string(forKey: "avatar") ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "avatar")
            User.rxMine.value = self
        }
    }

    var carHeadId: Int {
        get {
            let tmp = UserDefaults.standard.integer(forKey: "car_head_id")
            return  tmp == 0 ? 201 : tmp
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "car_head_id")
            User.rxMine.value = self
        }
    }

    var carHeadBg: Int {
        get {
            let tmp = UserDefaults.standard.integer(forKey: "car_head_bg")
            return tmp == 0 ? 101 : tmp
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "car_head_bg")
            User.rxMine.value = self
        }
    }

    func setAvatarImage(_ imageView: UIImageView) {
        imageView.updateAvatar(Mine.sharedInstance.id, url: Mine.sharedInstance.avatarUrl, tappable: false, inVC: nil)
    }

    mutating func updateLogin(_ user: User) {
        if user.car != "" {
            self.car = user.car
        }
        if user.phone != "" {
            self.phone = user.phone
        }
        if user.id != "" {
            self.id = user.id
        }

        if user.token != "" {
            self.token = user.token
        }
        if user.nickname != "" {
            self.nickname = user.nickname
        }
        if let sex = user.sex {
            self.sex = sex
        }
        if user.img != "" {
            self.avatarUrl = user.img
        }
    }

    mutating func logout(expired: Bool = true) {
        RCIM.shared().disconnect(false)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        KingfisherManager.sharedManager.cache.clearDiskCache()
        main {
            gRealm?.writeOptional {
                if let objects = gRealm?.allObjects(ofType: RmScore.self) {
                    gRealm?.delete(objects)
                }
                if let objects = gRealm?.allObjects(ofType: RmScoreData.self) {
                    gRealm?.delete(objects)
                }
                if let objects = gRealm?.allObjects(ofType: CarInfo.self) {
                    gRealm?.delete(objects)
                }
            }
            let firstController = R.storyboard.login.login!
            let window = UIApplication.shared().keyWindow
            window?.rootViewController = firstController

            if expired {
                Toast.makeToast(message: "登录信息已过期，请重新登录")
            }
        }
    }
}
