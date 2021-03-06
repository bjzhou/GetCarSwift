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

        loginViewModel = LoginViewModel(phoneText: phoneText.rx.textInput.text, codeText: vcodeText.rx.textInput.text)
        loginViewModel.viewProxy = self

        loginViewModel.codeEnabled.asObservable().bindTo(vcodeButton.rx.enabled).addDisposableTo(disposeBag)
        loginViewModel.codeTitle.asObservable().subscribe(onNext: { title in
            self.vcodeButton.setTitle(title, for: .normal)
        }).addDisposableTo(disposeBag)
    }

    // MARK: IBOutlet Actions

    @IBAction func onLoginAction(_ sender: UIButton) {
        loginViewModel.onLoginAction()
    }

    @IBAction func onVCodeAction(_ sender: UIButton) {
        loginViewModel.onCodeButtonAction()
    }

}
