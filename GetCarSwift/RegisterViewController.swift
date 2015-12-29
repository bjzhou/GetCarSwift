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

        registerViewModel = RegisterViewModel(nickname: nickname.rx_text)
        registerViewModel.viewProxy = self
    }

    @IBAction func onRegister(sender: UIButton) {
        registerViewModel.didRegister()
    }

    func didCarSelected(car: CarInfo) {
        registerViewModel.car = car
        carText.text = car.model
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.choose_car {
            let dest = segue.destinationViewController as? CarTableNavigationController
            dest?.carDelegate = self
        }
    }
    @IBAction func didSexChange(sender: UIButton) {
        sender.selected = true
        let otherButton = self.view.viewWithTag(sender.tag == 501 ? 502 : 501) as? UIButton
        otherButton?.selected = false
        registerViewModel.sex = sender.tag == 501 ? 1 : 0
    }
}
