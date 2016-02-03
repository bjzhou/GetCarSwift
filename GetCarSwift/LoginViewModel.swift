//
//  LoginViewModel.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/24.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewModel {
    let disposeBag = DisposeBag()

    var phoneText: ControlProperty<String>
    var codeText: ControlProperty<String>

    var timerDisposable: Disposable?

    var viewProxy: ViewProxy?

    let codeEnabled = Variable(true)
    let codeTitle = Variable("发送验证码")

    init(phoneText: ControlProperty<String>, codeText: ControlProperty<String>) {
        self.phoneText = phoneText
        self.codeText = codeText

        self.phoneText.subscribeNext { _ in
            if self.codeEnabled.value == false {
                self.timerReset()
            }
        }.addDisposableTo(disposeBag)
    }

    func onLoginAction() {
        Observable.zip(phoneText, codeText) { phone, code in
            return (phone, code)
            }
            .take(1)
            .filter { phone, code in
                if phone.trim() == "" {
                    self.viewProxy?.showToast("请输入手机号")
                    return false
                }
                if code.trim() == "" {
                    self.viewProxy?.showToast("请输入验证码")
                    return false
                }
                return true
            }
            .map { phone, code in
                User.login(phone: phone, code: code)
            }
            .concat()
            .subscribeNext { res in
                guard let user = res.data where user.token.trim() != "" else {
                    if res.code == -25 {
                        self.viewProxy?.showToast("验证码错误")
                    } else if res.code == -26 {
                        self.viewProxy?.showToast("验证码已过期")
                    } else {
                        self.viewProxy?.showToast("登陆失败")
                    }
                    return
                }

                Mine.sharedInstance.token = user.token

                if user.nickname != "" {
                    Mine.sharedInstance.updateLogin(user)
                    self.viewProxy?.setRootViewController()
                } else {
                    let dest = R.storyboard.login.register!
                    self.viewProxy?.showViewController(dest)
                }
        }.addDisposableTo(disposeBag)
    }

    func onCodeButtonAction() {
        phoneText
            .take(1)
            .filter { phone in
                if phone.characters.count < 11 {
                    self.viewProxy?.showToast("手机号格式错误")
                    return false
                }

                self.timerDisposable = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).subscribeNext { time in
                    self.codeEnabled.value = false
                    self.codeTitle.value = String(60-time) + "秒后重新发送"
                    if time == 60 {
                        self.timerReset()
                    }
                }
                return true
            }
            .map { phone in
                return User.getCodeMsg(phone)
            }
            .concat()
            .subscribe(onNext: { res in
                if res.code == 0 {
                    self.viewProxy?.showToast("验证码发送成功")
                } else {
                    self.viewProxy?.showToast("验证码发送失败")
                    self.timerReset()
                }
                }, onError: { _ in
                    self.viewProxy?.showToast("验证码发送失败")
                    self.timerReset()
                })
            .addDisposableTo(disposeBag)
    }

    func timerReset() {
        timerDisposable?.dispose()
        codeEnabled.value = true
        codeTitle.value = "发送验证码"
    }
}
