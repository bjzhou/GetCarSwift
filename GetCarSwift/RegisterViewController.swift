//
//  RegisterViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/10.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class RegisterViewController: UIViewController, CarTableNavigationDelegate {

    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var carText: UITextField!

    var registerViewModel: RegisterViewModel!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        addEndEditingGesture(self.view)

        registerViewModel = RegisterViewModel(nickname: nickname.rx.textInput.text)
        registerViewModel.viewProxy = self
    }

    @IBAction func onRegister(_ sender: UIButton) {
        registerViewModel.didRegister()
    }

    func didCarSelected(_ car: CarInfo) {
        registerViewModel.car = car
        carText.text = car.model
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.registerViewController.choose_car.identifier {
            let dest = segue.destination as? CarTableNavigationController
            dest?.carDelegate = self
        }
    }
    @IBAction func didSexChange(_ sender: UIButton) {
        sender.isSelected = true
        let otherButton = self.view.viewWithTag(sender.tag == 501 ? 502 : 501) as? UIButton
        otherButton?.isSelected = false
        registerViewModel.sex = sender.tag == 501 ? 1 : 0
    }
}
