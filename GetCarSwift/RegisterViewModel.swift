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
                if self.car.model.trim() == "" {
                    self.viewProxy?.showToast("请选择或输入车型")
                    return false
                }
                return true
            }
            .map { nick in
                User.updateInfo(nickname: nick, sex: self.sex, carInfos: [self.car])
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
