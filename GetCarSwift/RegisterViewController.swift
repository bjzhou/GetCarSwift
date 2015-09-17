//
//  RegisterViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, CarTableNavigationDelegate {

    var sex: Int = 1
    var selectedCarId: String?

    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var carLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: "didSingleTap")
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }

    func didSingleTap() {
        self.view.endEditing(true)
    }

    @IBAction func onRegister(sender: UIButton) {
        switch(nickname.text!.trim(), selectedCarId) {
        case ("", _):
            self.view.makeToast(message: "请输入用户昵称")
        case (_, .None):
            self.view.makeToast(message: "请选择车型")
        case (let nicknameText, let .Some(selectedCarId)):
            UserApi.sharedInstance.updateInfo(nickname: nicknameText, sex: sex, car: selectedCarId) { result in
                guard let json = result.data else {
                    self.view.makeToast(message: "注册失败")
                    return
                }

                if result.code >= 0 {
                    updateLogin(json)

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateInitialViewController()
                    UIApplication.sharedApplication().keyWindow?.rootViewController = controller
                }
            }
        }
    }

    func didCarSelected(car: String) {
        carLabel.text = car
        selectedCarId = car
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "choose_car" {
            let dest = segue.destinationViewController as! CarTableNavigationController
            dest.carDelegate = self
        }
    }
    @IBAction func didSexChange(sender: UIButton) {
        sender.selected = true
        let otherButton = self.view.viewWithTag(sender.tag == 501 ? 502 : 501) as! UIButton
        otherButton.selected = false
        sex = sender.tag == 501 ? 1 : 0
    }
}
