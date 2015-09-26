//
//  LoginViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var vcodeText: UITextField!
    @IBOutlet weak var vcodeButton: UIButton!

    var loginViewModel: LoginViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        phoneText.becomeFirstResponder()

        loginViewModel = LoginViewModel(phoneText: phoneText.rx_text, codeText: vcodeText.rx_text)
        loginViewModel.viewProxy = self

        loginViewModel.codeEnabled.bindTo(vcodeButton.rx_enabled)
        loginViewModel.codeTitle.subscribeNext { title in
            self.vcodeButton.setTitle(title, forState: .Normal)
        }
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // MARK: IBOutlet Actions

    @IBAction func onLoginAction(sender: UIButton) {
        loginViewModel.onLoginAction()
    }

    @IBAction func onVCodeAction(sender: UIButton) {
        loginViewModel.onCodeButtonAction()
    }

}

extension LoginViewController: ViewProxy {

    func showToast(toast: String) {
        self.view.makeToast(message: toast)
    }

    func showViewController(vc: UIViewController) {
        self.showViewController(vc, sender: self)
    }

}
