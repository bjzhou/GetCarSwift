//
//  RegisterViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    var phone: String?
    var code: String?

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var sex: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func onRegister(sender: UIButton) {
        if let phone = phone, code = code {
            switch(username.text, password.text) {
            case (.Some(let usernameText), .Some(let passwordText)):
                register(phone, password: passwordText, code: code, sex: sex.text ?? "", username: usernameText, nickname: nickname.text ?? "").responseJSON { (req, res, data) in
                    guard let value = data.value else {
                        if let raw = data.data {
                            print(NSString(data: raw, encoding: NSUTF8StringEncoding))
                        }
                        self.view.makeToast(message: "注册失败")
                        return
                    }

                    print(value)
                }
            case (.None, .Some):
                self.view.makeToast(message: "用户名不能为空")
            case (.Some, .None):
                self.view.makeToast(message: "密码不能为空")
            case (.None, .None):
                self.view.makeToast(message: "用户名和密码不能为空")
            }
        } else {
            print("error: \(phone), \(code)")
        }
    }
}
