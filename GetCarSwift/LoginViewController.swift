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
    
    var code: UInt32 = 0;
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBOutlet Actions
    
    @IBAction func onLoginAction(sender: UIButton) {
        if code == 0 {return}
        if vcodeText.text == String(code) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "isLogin")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateInitialViewController()
            UIApplication.sharedApplication().keyWindow?.rootViewController = controller
        }
    }

    @IBAction func onVCodeAction(sender: UIButton) {
        guard let phone = phoneText.text where phone.characters.count >= 11 else {
            self.view.makeToast(message: "手机号格式错误")
            return
        }
        timerCount = 0
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("onTimeUpdate:"), userInfo: sender, repeats: true)
        getCodeMsg(phone).responseJSON { (req, res, data) in
            guard let jsonValue = data.value else {
                print(data.error?.description)
                self.view.makeToast(message: "网络错误")
                return
            }
            
            let result = ApiResult<CodeMsg>(json: jsonValue)
            if result.code < 0 {
                self.view.makeToast(message: result.msg)
                self.timerReset(timer)
            } else {
                self.vcodeText.text = result.data.code
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
