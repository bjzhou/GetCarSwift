//
//  LoginViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var vcodeText: UITextField!

    var code: String = "";
    var timerCount = 0;

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        phoneText.becomeFirstResponder()
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: IBOutlet Actions

    @IBAction func onLoginAction(sender: UIButton) {
        switch (phoneText.text!.trim(), vcodeText.text!.trim()) {
        case ("", _):
            self.view.makeToast(message: "请输入手机号")
        case (_, ""):
            self.view.makeToast(message: "请输入验证码")
        case (let phone, let code):
            UserApi.sharedInstance.login(phone: phone, code: code) { result in
                if let json = result.data {
                    if result.code < 0 {
                        self.view.makeToast(message: "验证码错误")
                        return
                    }

                    DataKeeper.sharedInstance.token = json["token"].stringValue

                    if json["nickname"].stringValue == "" {
                        let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("register") as! UIViewController
                        self.showViewController(dest, sender: self)
                    } else {
                        updateLogin(json)

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateInitialViewController() as! UIViewController
                        UIApplication.sharedApplication().keyWindow?.rootViewController = controller
                    }
                } else {
                    self.view.makeToast(message: "登陆失败")
                    return
                }
            }
        }
    }

    @IBAction func onVCodeAction(sender: UIButton) {
        if let phone = phoneText.text where phone.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= 11 {
            timerCount = 0
            let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("onTimeUpdate:"), userInfo: sender, repeats: true)
            timer.fire()
            UserApi.sharedInstance.getCodeMsg(phone) { result in
                if result.error == nil {
                    self.view.makeToast(message: "验证码已发送")
                } else {
                    self.view.makeToast(message: "验证码发送失败")
                }
            }
        } else {
            self.view.makeToast(message: "手机号格式错误")
            return
        }
    }

    @IBAction func oSkipAction(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! UIViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = controller
    }

    func onTimeUpdate(timer: NSTimer) {
        timerCount++
        let button = timer.userInfo as? UIButton
        if timerCount==60 {
            timerReset(timer)
            return
        }
        button?.enabled = false
        button?.setTitle(String(60-timerCount) + "秒后重新发送", forState: .Normal)
    }

    func timerReset(timer: NSTimer) {
        let button = timer.userInfo as? UIButton
        timer.invalidate()
        button?.enabled = true
        button?.setTitle("发送验证码", forState: .Normal)
    }
}
