//
//  LoginViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var vcodeText: UITextField!
    @IBOutlet weak var vcodeButton: UIButton!

    var loginViewModel: LoginViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        addEndEditingGesture(self.view)

        phoneText.becomeFirstResponder()

        loginViewModel = LoginViewModel(phoneText: phoneText.rx_text, codeText: vcodeText.rx_text)
        loginViewModel.viewProxy = self

        loginViewModel.codeEnabled.bindTo(vcodeButton.rx_enabled).addDisposableTo(disposeBag)
        loginViewModel.codeTitle.subscribeNext { title in
            self.vcodeButton.setTitle(title, forState: .Normal)
        }.addDisposableTo(disposeBag)
    }

    // MARK: IBOutlet Actions

    @IBAction func onLoginAction(sender: UIButton) {
        loginViewModel.onLoginAction()
    }

    @IBAction func onVCodeAction(sender: UIButton) {
        loginViewModel.onCodeButtonAction()
    }

}
