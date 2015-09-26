//
//  RegisterViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, CarTableNavigationDelegate {

    var registerViewModel: RegisterViewModel!

    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var carLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: "didSingleTap")
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)

        registerViewModel = RegisterViewModel(nickname: nickname.rx_text)
        registerViewModel.viewProxy = self
    }

    func didSingleTap() {
        self.view.endEditing(true)
    }

    @IBAction func onRegister(sender: UIButton) {
        registerViewModel.didRegister()
    }

    func didCarSelected(car: String) {
        carLabel.text = car
        registerViewModel.car = car
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
        registerViewModel.sex = sender.tag == 501 ? 1 : 0
    }
}
