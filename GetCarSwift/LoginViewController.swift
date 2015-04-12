//
//  LoginViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBOutlet Actions
    
    @IBAction func onLoginAction(sender: UIButton) {
        if count(username.text) == 0 {
            UIAlertView(title: "用户名不能为空", message: nil, delegate: nil, cancelButtonTitle: "好").show()
            return
        }
        
        if count(password.text) < 6 {
            UIAlertView(title: "密码必须是大于6位的任意数字或字母", message: nil, delegate: nil, cancelButtonTitle: "好").show()
            return
        }
        
        if username.text == "gaike" && password.text == "123456" {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "isLogin")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var controller = storyboard.instantiateInitialViewController() as! UIViewController
            UIApplication.sharedApplication().keyWindow?.rootViewController = controller
        }
    }

    @IBAction func onRegisterAction(sender: UIButton) {
    }

}
