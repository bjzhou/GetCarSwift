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
        if phoneText.text!.characters.count < 11 {
            return
        }
        timerCount = 0
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("onTimeUpdate:"), userInfo: sender, repeats: true)
        code = arc4random_uniform(900000) + 100000
        let alert = UIAlertController(title: "验证码", message: String(code), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
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
            timer.invalidate()
            button?.enabled = true
            button?.setTitle("发送验证码", forState: .Normal)
            return
        }
        button?.enabled = false
        button?.setTitle(String(60-timerCount) + "秒后重新发送", forState: .Normal)
    }

}
