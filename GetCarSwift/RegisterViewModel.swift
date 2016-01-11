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

    var sex = 1
    var nickname: ControlProperty<String>
    var car = CarInfo()

    var viewProxy: ViewProxy?

    init(nickname: ControlProperty<String>) {
        self.nickname = nickname
    }

    func didRegister() {
        nickname.take(1)
            .filter { nick in
                if nick.trim() == "" {
                    self.viewProxy?.showToast("请输入用户昵称")
                    return false
                }
                return true
            }
            .map { nick in
                User.updateInfo(nickname: nick, sex: self.sex)
            }
            .concat()
            .subscribeNext { res in
                guard let user = res.data else {
                    self.viewProxy?.showToast("注册失败")
                    return
                }

                if res.code >= 0 {
                    Mine.sharedInstance.updateLogin(user)
                    if self.car.modelId != 0 {
                        _ = CarInfo.addUserCar(self.car.modelId).subscribe()
                    }
                    self.viewProxy?.setRootViewController()
                }
            }.addDisposableTo(disposeBag)
    }
}
