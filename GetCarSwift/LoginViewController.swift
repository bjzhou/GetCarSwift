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
            UserApi.login(phone, code: code).responseGKJSON { (req, res, result) in
                guard let json = result.json else {
                    self.view.makeToast(message: "登陆失败")
                    return
                }

                if result.code < 0 {
                    self.view.makeToast(message: "验证码错误")
                    return
                }
                
                ApiHeader.sharedInstance.token = json["token"].stringValue
                
                if json["nickname"].stringValue == "" {
                    let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("register")
                    self.showViewController(dest, sender: self)
                } else {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true, forKey: "isLogin")
                    defaults.setValue(json["nickname"].stringValue, forKey: "nickname")
                    defaults.setValue(json["sex"].intValue, forKey: "sex")
                    defaults.setValue(json["car"].stringValue, forKey: "car")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateInitialViewController()
                    UIApplication.sharedApplication().keyWindow?.rootViewController = controller
                }
            }
        }
    }

    @IBAction func onVCodeAction(sender: UIButton) {
        guard let phone = phoneText.text where phone.characters.count >= 11 else {
            self.view.makeToast(message: "手机号格式错误")
            return
        }
        timerCount = 0
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("onTimeUpdate:"), userInfo: sender, repeats: true)
        timer.fire()
        UserApi.getCodeMsg(phone).response { (req, res, data, err) in
            if err == nil {
                self.view.makeToast(message: "验证码已发送")
            } else {
                self.view.makeToast(message: "验证码发送失败")
            }
        }
    }

    @IBAction func oSkipAction(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()
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
