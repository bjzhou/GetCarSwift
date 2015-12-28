//
//  RegisterViewModel.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct RegisterViewModel {

    let disposeBag = DisposeBag()

    var sex = 0
    var nickname: ControlProperty<String>
    var car: ControlProperty<String>

    var viewProxy: ViewProxy?

    init(nickname: ControlProperty<String>, car: ControlProperty<String>) {
        self.nickname = nickname
        self.car = car
    }

    func didRegister() {
        combineLatest(nickname, car) { ($0, $1) }.take(1)
            .filter { (nick, car) in
                if nick.trim() == "" {
                    self.viewProxy?.showToast("请输入用户昵称")
                    return false
                }
                if car.trim() == "" {
                    self.viewProxy?.showToast("请选择或输入车型")
                    return false
                }
                return true
            }
            .map { (nick, car) in
                User.updateInfo(nickname: nick, sex: self.sex, carInfos: [CarInfo(value: ["model": car])])
            }
            .concat()
            .subscribeNext { res in
                guard let user = res.data else {
                    self.viewProxy?.showToast("注册失败")
                    return
                }

                if res.code >= 0 {
                    Mine.sharedInstance.updateLogin(user)
                    self.viewProxy?.setRootViewController()
                }
            }.addDisposableTo(disposeBag)
    }
}
